

@SILdoc(`Validate a ZFS path.  This is used even before trying to open the dataset, to provide a more meaningful error message.  We call zfs_error_aux() to explain exactly why the name was not valid.`)
void validateName(string path, ZfsType type, bool modifying)
{
	enforce(libZfsHandle !is null, "you must open libzfs before calling this function");

	if (type == ZfsType.pool)
		return zpool_name_valid(null,0,name.toCString);

	switch(type) with(ZfsType)
	{
		case snapshot:
			enforce(path.canFind("@"),"missing '@' delimiter in snapshot name");
			break;

		case bookmark:
			enforce(!path.canFind("@"),"snapshot delimiter '@' is not expected here");
			enforce(path.canFind("#"),"missing '#' delimiter in bookmark name");

		default:	
			enforce(!path.canFind("#"),"boomark delimiter '#' is not expected here");
			enforce(!path.canFind("@"),"snapshot delimiter '@' is not expected here");
	}

	enforce(!modifying || !path.canFind("%"), "invalid character % in name");
	auto nameCheck = path.entityNameCheck;
	enforce(nameCheck.success,nameCheck.entityNameCheckReason);
}

struct EntityNameCheckResult
{
	bool succcess;
	namecheck_err_t why;
	char what;
}

auto entityNameCheck(string path)
{
	EntityNameCheckResult ret;
	ret.success = (entity_namecheck(path.toCString, &ret.why, &ret.what) != 0);
	return ret;
}

string entityNameCheckReason(EntityNameCheckResult result)
{
	if (result.success)
		return "okay";

	switch(result.why)
	{
		case NAME_ERR_TOOLONG:
			return "name is too long";

		case NAME_ERR_LEADING_SLASH:
			return "leading slash in name";

		case NAME_ERR_EMPTY_COMPONENT:
			return "empty component or misplaced '@' or '#' delimiter in name";

		case NAME_ERR_TRAILING_SLASH:
			return "trailing slash in name";

		case NAME_ERR_INVALCHAR:
			return format!"invalid character %c in name"(result.what);
			
		case NAME_ERR_MULTIPLE_DELIMITERS:
			return "multiple '@' and/or '#' delimiters in name";

		case NAME_ERR_NOLETTER:
			return "pool doesn't begin with a letter";

		case NAME_ERR_RESERVED:
			return "name is reserved";

		case NAME_ERR_DISKLIKE:
			return "reserved disk name";

		case NAME_ERR_SELF_REF:
			return "self reference, '.' is found in name";

		case NAME_ERR_PARENT_REF:
			return "parent reference, '..' is found in name";

		default:
			return format!"(%d) not defined"(result.why);
	}
	assert(0);
}

@SILdoc(`Given an nvlist of properties to set, validates that they are correct, and parses any numeric properties (index, boolean, etc) if they are specified as strings`)
nvlist_t * validatePropertyList(libzfs_handle_t *hdl, zfs_type_t type, nvlist_t *nvl, ulong zoned, zfs_handle_t *zhp, zpool_handle_t *zpool_hdl, boolean_t key_params_ok, const char *errbuf)
{
	nvpair_t *elem;
	ulong intval;
	char *strval;
	zfs_prop_t prop;
	nvlist_t *ret;
	int chosen_normal = -1;
	int chosen_utf = -1;

	if (nvlist_alloc(&ret, NV_UNIQUE_NAME, 0) != 0) {
		(void) no_memory(hdl);
		return (null);
	}

	/*
	 * Make sure this property is valid and applies to this type.
	 */

	elem = null;
	while ((elem = nvlist_next_nvpair(nvl, elem)) !is null) {
		const char *propname = nvpair_name(elem);

		prop = zfs_name_to_prop(propname);
		if (prop == ZPROP_INVAL && zfs_prop_user(propname)) {
			/*
			 * This is a user property: make sure it's a
			 * string, and that it's less than ZAP_MAXNAMELEN.
			 */
			if (nvpair_type(elem) != DATA_TYPE_STRING) {
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
				    "'%s' must be a string"), propname);
				(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
				goto error;
			}

			if (strlen(nvpair_name(elem)) >= ZAP_MAXNAMELEN) {
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
				    "property name '%s' is too long"),
				    propname);
				(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
				goto error;
			}

			(void) nvpair_value_string(elem, &strval);
			if (nvlist_add_string(ret, propname, strval) != 0) {
				(void) no_memory(hdl);
				goto error;
			}
			continue;
		}

		/*
		 * Currently, only user properties can be modified on
		 * snapshots.
		 */
		if (type == ZFS_TYPE_SNAPSHOT) {
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "this property can not be modified for snapshots"));
			(void) zfs_error(hdl, EZFS_PROPTYPE, errbuf);
			goto error;
		}

		if (prop == ZPROP_INVAL && zfs_prop_userquota(propname)) {
			zfs_userquota_prop_t uqtype;
			char *newpropname = null;
			char domain[128];
			ulong rid;
			ulong valary[3];
			int rc;

			if (userquota_propname_decode(propname, zoned,
			    &uqtype, domain, sizeof (domain), &rid) != 0) {
				zfs_error_aux(hdl,
				    dgettext(TEXT_DOMAIN,
				    "'%s' has an invalid user/group name"),
				    propname);
				(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
				goto error;
			}

			if (uqtype != ZFS_PROP_USERQUOTA &&
			    uqtype != ZFS_PROP_GROUPQUOTA &&
			    uqtype != ZFS_PROP_USEROBJQUOTA &&
			    uqtype != ZFS_PROP_GROUPOBJQUOTA &&
			    uqtype != ZFS_PROP_PROJECTQUOTA &&
			    uqtype != ZFS_PROP_PROJECTOBJQUOTA) {
				zfs_error_aux(hdl,
				    dgettext(TEXT_DOMAIN, "'%s' is readonly"),
				    propname);
				(void) zfs_error(hdl, EZFS_PROPREADONLY,
				    errbuf);
				goto error;
			}

			if (nvpair_type(elem) == DATA_TYPE_STRING) {
				(void) nvpair_value_string(elem, &strval);
				if (strcmp(strval, "none") == 0) {
					intval = 0;
				} else if (zfs_nicestrtonum(hdl,
				    strval, &intval) != 0) {
					(void) zfs_error(hdl,
					    EZFS_BADPROP, errbuf);
					goto error;
				}
			} else if (nvpair_type(elem) ==
			    DATA_TYPE_UINT64) {
				(void) nvpair_value_uint64(elem, &intval);
				if (intval == 0) {
					zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
					    "use 'none' to disable "
					    "{user|group|project}quota"));
					goto error;
				}
			} else {
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
				    "'%s' must be a number"), propname);
				(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
				goto error;
			}

			/*
			 * Encode the prop name as
			 * userquota@<hex-rid>-domain, to make it easy
			 * for the kernel to decode.
			 */
			rc = asprintf(&newpropname, "%s%llx-%s",
			    zfs_userquota_prop_prefixes[uqtype],
			    (longlong_t)rid, domain);
			if (rc == -1 || newpropname is null) {
				(void) no_memory(hdl);
				goto error;
			}

			valary[0] = uqtype;
			valary[1] = rid;
			valary[2] = intval;
			if (nvlist_add_uint64_array(ret, newpropname,
			    valary, 3) != 0) {
				free(newpropname);
				(void) no_memory(hdl);
				goto error;
			}
			free(newpropname);
			continue;
		} else if (prop == ZPROP_INVAL && zfs_prop_written(propname)) {
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "'%s' is readonly"),
			    propname);
			(void) zfs_error(hdl, EZFS_PROPREADONLY, errbuf);
			goto error;
		}

		if (prop == ZPROP_INVAL) {
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "invalid property '%s'"), propname);
			(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
			goto error;
		}

		if (!zfs_prop_valid_for_type(prop, type, B_FALSE)) {
			zfs_error_aux(hdl,
			    dgettext(TEXT_DOMAIN, "'%s' does not "
			    "apply to datasets of this type"), propname);
			(void) zfs_error(hdl, EZFS_PROPTYPE, errbuf);
			goto error;
		}

		if (zfs_prop_readonly(prop) &&
		    !(zfs_prop_setonce(prop) && zhp is null) &&
		    !(zfs_prop_encryption_key_param(prop) && key_params_ok)) {
			zfs_error_aux(hdl,
			    dgettext(TEXT_DOMAIN, "'%s' is readonly"),
			    propname);
			(void) zfs_error(hdl, EZFS_PROPREADONLY, errbuf);
			goto error;
		}

		if (zprop_parse_value(hdl, elem, prop, type, ret,
		    &strval, &intval, errbuf) != 0)
			goto error;

		/*
		 * Perform some additional checks for specific properties.
		 */
		switch (prop) {
		case ZFS_PROP_VERSION:
		{
			int version;

			if (zhp is null)
				break;
			version = zfs_prop_get_int(zhp, ZFS_PROP_VERSION);
			if (intval < version) {
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
				    "Can not downgrade; already at version %u"),
				    version);
				(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
				goto error;
			}
			break;
		}

		case ZFS_PROP_VOLBLOCKSIZE:
		case ZFS_PROP_RECORDSIZE:
		{
			int maxbs = SPA_MAXBLOCKSIZE;
			char buf[64];

			if (zpool_hdl !is null) {
				maxbs = zpool_get_prop_int(zpool_hdl,
				    ZPOOL_PROP_MAXBLOCKSIZE, null);
			}
			/*
			 * The value must be a power of two between
			 * SPA_MINBLOCKSIZE and maxbs.
			 */
			if (intval < SPA_MINBLOCKSIZE ||
			    intval > maxbs || !ISP2(intval)) {
				zfs_nicebytes(maxbs, buf, sizeof (buf));
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
				    "'%s' must be power of 2 from 512B "
				    "to %s"), propname, buf);
				(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
				goto error;
			}
			break;
		}

		case ZFS_PROP_SPECIAL_SMALL_BLOCKS:
			if (zpool_hdl !is null) {
				char state[64] = "";

				/*
				 * Issue a warning but do not fail so that
				 * tests for setable properties succeed.
				 */
				if (zpool_prop_get_feature(zpool_hdl,
				    "feature@allocation_classes", state,
				    sizeof (state)) != 0 ||
				    strcmp(state, ZFS_FEATURE_ACTIVE) != 0) {
					(void) fprintf(stderr, gettext(
					    "%s: property requires a special "
					    "device in the pool\n"), propname);
				}
			}
			if (intval != 0 &&
			    (intval < SPA_MINBLOCKSIZE ||
			    intval > SPA_OLD_MAXBLOCKSIZE || !ISP2(intval))) {
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
				    "invalid '%s=%d' property: must be zero or "
				    "a power of 2 from 512B to 128K"), propname,
				    intval);
				(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
				goto error;
			}
			break;

		case ZFS_PROP_MLSLABEL:
		{
#ifdef HAVE_MLSLABEL
			/*
			 * Verify the mlslabel string and convert to
			 * internal hex label string.
			 */

			m_label_t *new_sl;
			char *hex = null;	/* internal label string */

			/* Default value is already OK. */
			if (strcasecmp(strval, ZFS_MLSLABEL_DEFAULT) == 0)
				break;

			/* Verify the label can be converted to binary form */
			if (((new_sl = m_label_alloc(MAC_LABEL)) is null) ||
			    (str_to_label(strval, &new_sl, MAC_LABEL,
			    L_NO_CORRECTION, null) == -1)) {
				goto badlabel;
			}

			/* Now translate to hex internal label string */
			if (label_to_str(new_sl, &hex, M_INTERNAL,
			    DEF_NAMES) != 0) {
				if (hex)
					free(hex);
				goto badlabel;
			}
			m_label_free(new_sl);

			/* If string is already in internal form, we're done. */
			if (strcmp(strval, hex) == 0) {
				free(hex);
				break;
			}

			/* Replace the label string with the internal form. */
			(void) nvlist_remove(ret, zfs_prop_to_name(prop),
			    DATA_TYPE_STRING);
			verify(nvlist_add_string(ret, zfs_prop_to_name(prop),
			    hex) == 0);
			free(hex);

			break;

badlabel:
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "invalid mlslabel '%s'"), strval);
			(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
			m_label_free(new_sl);	/* OK if null */
			goto error;
#else
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "mlslabels are unsupported"));
			(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
			goto error;
#endif /* HAVE_MLSLABEL */
		}

		case ZFS_PROP_MOUNTPOINT:
		{
			namecheck_err_t why;

			if (strcmp(strval, ZFS_MOUNTPOINT_NONE) == 0 ||
			    strcmp(strval, ZFS_MOUNTPOINT_LEGACY) == 0)
				break;

			if (mountpoint_namecheck(strval, &why)) {
				switch (why) {
				case NAME_ERR_LEADING_SLASH:
					zfs_error_aux(hdl,
					    dgettext(TEXT_DOMAIN,
					    "'%s' must be an absolute path, "
					    "'none', or 'legacy'"), propname);
					break;
				case NAME_ERR_TOOLONG:
					zfs_error_aux(hdl,
					    dgettext(TEXT_DOMAIN,
					    "component of '%s' is too long"),
					    propname);
					break;

				default:
					zfs_error_aux(hdl,
					    dgettext(TEXT_DOMAIN,
					    "(%d) not defined"),
					    why);
					break;
				}
				(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
				goto error;
			}
		}

			/*FALLTHRU*/

		case ZFS_PROP_SHARESMB:
		case ZFS_PROP_SHARENFS:
			/*
			 * For the mountpoint and sharenfs or sharesmb
			 * properties, check if it can be set in a
			 * global/non-global zone based on
			 * the zoned property value:
			 *
			 *		global zone	    non-global zone
			 * --------------------------------------------------
			 * zoned=on	mountpoint (no)	    mountpoint (yes)
			 *		sharenfs (no)	    sharenfs (no)
			 *		sharesmb (no)	    sharesmb (no)
			 *
			 * zoned=off	mountpoint (yes)	N/A
			 *		sharenfs (yes)
			 *		sharesmb (yes)
			 */
			if (zoned) {
				if (getzoneid() == GLOBAL_ZONEID) {
					zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
					    "'%s' cannot be set on "
					    "dataset in a non-global zone"),
					    propname);
					(void) zfs_error(hdl, EZFS_ZONED,
					    errbuf);
					goto error;
				} else if (prop == ZFS_PROP_SHARENFS ||
				    prop == ZFS_PROP_SHARESMB) {
					zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
					    "'%s' cannot be set in "
					    "a non-global zone"), propname);
					(void) zfs_error(hdl, EZFS_ZONED,
					    errbuf);
					goto error;
				}
			} else if (getzoneid() != GLOBAL_ZONEID) {
				/*
				 * If zoned property is 'off', this must be in
				 * a global zone. If not, something is wrong.
				 */
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
				    "'%s' cannot be set while dataset "
				    "'zoned' property is set"), propname);
				(void) zfs_error(hdl, EZFS_ZONED, errbuf);
				goto error;
			}

			/*
			 * At this point, it is legitimate to set the
			 * property. Now we want to make sure that the
			 * property value is valid if it is sharenfs.
			 */
			if ((prop == ZFS_PROP_SHARENFS ||
			    prop == ZFS_PROP_SHARESMB) &&
			    strcmp(strval, "on") != 0 &&
			    strcmp(strval, "off") != 0) {
				zfs_share_proto_t proto;

				if (prop == ZFS_PROP_SHARESMB)
					proto = PROTO_SMB;
				else
					proto = PROTO_NFS;

				/*
				 * Must be an valid sharing protocol
				 * option string so init the libshare
				 * in order to enable the parser and
				 * then parse the options. We use the
				 * control API since we don't care about
				 * the current configuration and don't
				 * want the overhead of loading it
				 * until we actually do something.
				 */

				if (zfs_init_libshare(hdl,
				    SA_INIT_CONTROL_API) != SA_OK) {
					/*
					 * An error occurred so we can't do
					 * anything
					 */
					zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
					    "'%s' cannot be set: problem "
					    "in share initialization"),
					    propname);
					(void) zfs_error(hdl, EZFS_BADPROP,
					    errbuf);
					goto error;
				}

				if (zfs_parse_options(strval, proto) != SA_OK) {
					/*
					 * There was an error in parsing so
					 * deal with it by issuing an error
					 * message and leaving after
					 * uninitializing the the libshare
					 * interface.
					 */
					zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
					    "'%s' cannot be set to invalid "
					    "options"), propname);
					(void) zfs_error(hdl, EZFS_BADPROP,
					    errbuf);
					zfs_uninit_libshare(hdl);
					goto error;
				}
				zfs_uninit_libshare(hdl);
			}

			break;

		case ZFS_PROP_KEYLOCATION:
			if (!zfs_prop_valid_keylocation(strval, B_FALSE)) {
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
				    "invalid keylocation"));
				(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
				goto error;
			}

			if (zhp !is null) {
				ulong crypt =
				    zfs_prop_get_int(zhp, ZFS_PROP_ENCRYPTION);

				if (crypt == ZIO_CRYPT_OFF &&
				    strcmp(strval, "none") != 0) {
					zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
					    "keylocation must be 'none' "
					    "for unencrypted datasets"));
					(void) zfs_error(hdl, EZFS_BADPROP,
					    errbuf);
					goto error;
				} else if (crypt != ZIO_CRYPT_OFF &&
				    strcmp(strval, "none") == 0) {
					zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
					    "keylocation must not be 'none' "
					    "for encrypted datasets"));
					(void) zfs_error(hdl, EZFS_BADPROP,
					    errbuf);
					goto error;
				}
			}
			break;

		case ZFS_PROP_PBKDF2_ITERS:
			if (intval < MIN_PBKDF2_ITERATIONS) {
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
				    "minimum pbkdf2 iterations is %u"),
				    MIN_PBKDF2_ITERATIONS);
				(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
				goto error;
			}
			break;

		case ZFS_PROP_UTF8ONLY:
			chosen_utf = (int)intval;
			break;

		case ZFS_PROP_NORMALIZE:
			chosen_normal = (int)intval;
			break;

		default:
			break;
		}

		/*
		 * For changes to existing volumes, we have some additional
		 * checks to enforce.
		 */
		if (type == ZFS_TYPE_VOLUME && zhp !is null) {
			ulong blocksize = zfs_prop_get_int(zhp,
			    ZFS_PROP_VOLBLOCKSIZE);
			char buf[64];

			switch (prop) {
			case ZFS_PROP_VOLSIZE:
				if (intval % blocksize != 0) {
					zfs_nicebytes(blocksize, buf,
					    sizeof (buf));
					zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
					    "'%s' must be a multiple of "
					    "volume block size (%s)"),
					    propname, buf);
					(void) zfs_error(hdl, EZFS_BADPROP,
					    errbuf);
					goto error;
				}

				if (intval == 0) {
					zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
					    "'%s' cannot be zero"),
					    propname);
					(void) zfs_error(hdl, EZFS_BADPROP,
					    errbuf);
					goto error;
				}
				break;

			default:
				break;
			}
		}

		/* check encryption properties */
		if (zhp !is null) {
			int64_t crypt = zfs_prop_get_int(zhp,
			    ZFS_PROP_ENCRYPTION);

			switch (prop) {
			case ZFS_PROP_COPIES:
				if (crypt != ZIO_CRYPT_OFF && intval > 2) {
					zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
					    "encrypted datasets cannot have "
					    "3 copies"));
					(void) zfs_error(hdl, EZFS_BADPROP,
					    errbuf);
					goto error;
				}
				break;
			default:
				break;
			}
		}
	}

	/*
	 * If normalization was chosen, but no UTF8 choice was made,
	 * enforce rejection of non-UTF8 names.
	 *
	 * If normalization was chosen, but rejecting non-UTF8 names
	 * was explicitly not chosen, it is an error.
	 */
	if (chosen_normal > 0 && chosen_utf < 0) {
		if (nvlist_add_uint64(ret,
		    zfs_prop_to_name(ZFS_PROP_UTF8ONLY), 1) != 0) {
			(void) no_memory(hdl);
			goto error;
		}
	} else if (chosen_normal > 0 && chosen_utf == 0) {
		zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
		    "'%s' must be set 'on' if normalization chosen"),
		    zfs_prop_to_name(ZFS_PROP_UTF8ONLY));
		(void) zfs_error(hdl, EZFS_BADPROP, errbuf);
		goto error;
	}
	return (ret);

error:
	nvlist_free(ret);
	return (null);
}



void setPropertyError(zfs_prop_t prop, int err)
	, char *errbuf)
{
	libzfs_handle_t *hdl = libZfsHandle;
	switch (err)
	{
		case ENOSPC:
			// For quotas and reservations, ENOSPC indicates something different; setting a quota or reservation
			// doesn't use any disk space.
			switch (prop)
			{
				case quota, refQuota:
					zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "size is less than current used or reserved space"));
					(void) zfs_error(hdl, EZFS_PROPSPACE, errbuf);
					break;

				case reservation, refReservation:
					zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "size is greater than available space"));
					(void) zfs_error(hdl, EZFS_PROPSPACE, errbuf);
					break;

				default:
					zfs_standard_error(hdl, err, errbuf);
					break;
			}
			break;

		case EBUSY:
			zfs_standard_error(hdl, EBUSY, errbuf);
			break;

		case EROFS:
			zfs_error(hdl, EZFS_DSREADONLY, errbuf);
			break;

		case E2BIG:
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "property value too long"));
			zfs_error(hdl, EZFS_BADPROP, errbuf);
			break;

		case ENOTSUP:
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "pool and or dataset must be upgraded to set this property or value"));
			zfs_error(hdl, EZFS_BADVERSION, errbuf);
			break;

		case ERANGE:
			if (prop == ZFS_PROP_COMPRESSION || prop == ZFS_PROP_DNODESIZE || prop == ZFS_PROP_RECORDSIZE)
			{
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "property setting is not allowed on bootable datasets"));
				zfs_error(hdl, EZFS_NOTSUP, errbuf);
			} else if (prop == ZFS_PROP_CHECKSUM || prop == ZFS_PROP_DEDUP)
			{
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "property setting is not allowed on root pools"));
				zfs_error(hdl, EZFS_NOTSUP, errbuf);
			} else {
				zfs_standard_error(hdl, err, errbuf);
			}
			break;

	case EINVAL:
			if (prop == ZPROP_INVAL)
			{
				zfs_error(hdl, EZFS_BADPROP, errbuf);
			} else
			{
				zfs_standard_error(hdl, err, errbuf);
			}
			break;

		case EACCES:
			if (prop == ZFS_PROP_KEYLOCATION)
			{
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "keylocation may only be set on encryption roots"));
				zfs_error(hdl, EZFS_BADPROP, errbuf);
			} else
			{
				zfs_standard_error(hdl, err, errbuf);
			}
			break;

		case EOVERFLOW:
			 // This platform can't address a volume this big.
#ifdef _ILP32
			if (prop == ZFS_PROP_VOLSIZE) {
				zfs_error(hdl, EZFS_VOLTOOBIG, errbuf);
				break;
			}
#endif
			// FALLTHROUGH
		default:
			zfs_standard_error(hdl, err, errbuf);
	}
}

bool isNamespaceProperty(ZfsPropertyType property)
{
	switch (property) with(ZfsPropertyType)
	{
		case atime, relatime,devices,exec,setuid,readOnly,xattr,nbmand:
			return true;
		default:
			return false;
	}
}



// Accepts a property and value and checks that the value matches the one found by the channel program. If they are
// not equal, print both of them.
void zcp_check(zfs_handle_t *zhp, zfs_prop_t prop, ulong intval, const char *strval)
{
	if (!zhp.zfs_hdl.libzfs_prop_debug)
		return;
	int error;
	char *poolname = zhp.zpool_hdl.zpool_name;
	const char *prop_name = zfs_prop_to_name(prop);
	const char *program =
	    "args = ...\n"
	    "ds = args['dataset']\n"
	    "prop = args['property']\n"
	    "value, setpoint = zfs.get_prop(ds, prop)\n"
	    "return {value=value, setpoint=setpoint}\n";
	nvlist_t *outnvl;
	nvlist_t *retnvl;
	nvlist_t *argnvl = fnvlist_alloc();

	fnvlist_add_string(argnvl, "dataset", zhp.zfs_name);
	fnvlist_add_string(argnvl, "property", zfs_prop_to_name(prop));

	error = lzc_channel_program_nosync(poolname, program,
	    10 * 1000 * 1000, 10 * 1024 * 1024, argnvl, &outnvl);

	if (error == 0) {
		retnvl = fnvlist_lookup_nvlist(outnvl, "return");
		if (zfs_prop_get_type(prop) == PROP_TYPE_NUMBER) {
			int64_t ans;
			error = nvlist_lookup_int64(retnvl, "value", &ans);
			if (error != 0) {
				(void) fprintf(stderr, "%s: zcp check error: "
				    "%u\n", prop_name, error);
				return;
			}
			if (ans != intval) {
				(void) fprintf(stderr, "%s: zfs found %llu, "
				    "but zcp found %llu\n", prop_name,
				    (u_longlong_t)intval, (u_longlong_t)ans);
			}
		} else {
			char *str_ans;
			error = nvlist_lookup_string(retnvl, "value", &str_ans);
			if (error != 0) {
				(void) fprintf(stderr, "%s: zcp check error: "
				    "%u\n", prop_name, error);
				return;
			}
			if (strcmp(strval, str_ans) != 0) {
				(void) fprintf(stderr,
				    "%s: zfs found '%s', but zcp found '%s'\n",
				    prop_name, strval, str_ans);
			}
		}
	} else {
		(void) fprintf(stderr, "%s: zcp check failed, channel program "
		    "error: %u\n", prop_name, error);
	}
	nvlist_free(argnvl);
	nvlist_free(outnvl);
}


enum SmbAclOperation
{
	add = ZFS_SMB_ACL_ADD,
	remove = ZFS_SMB_ACL_REMOVE,
	rename = ZFS_SMB_ACL_RENAME,
	purge = ZFS_SMB_ACL_PURGE,
}

class ZfsException: Exception
{
	mixin basicExceptionCtors;
}


class ZfsMemoryAllocException: ZfsException
{
	mixin basicExceptionCtors;
}

ZfsMemoryAllocException* oom()
{
	return new ZfsMemoryAllocException("out of memory");
}

void safeCopy(char* dest, size_t size, string source)
{
	import std.algorithm:min,max;
	auto useSize = min(size,source.length+1);
	dest[0 .. useSize - 1] = source[0.. useSize -1];
	dest[useSize] = '\0';
}

