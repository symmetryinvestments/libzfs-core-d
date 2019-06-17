// not __gshared because the whole point is thread safety
libzfs_handle_t* libZfsHandle;

static this()
{
	libZfsHandle = libzfs_init();
}

static ~this()
{
}



@SILdoc(`Retrieve a property from the given object.  If 'literal' is specified, then numbers are left as exact values.  Otherwise, numbers are converted to a human-readable form.`)
string propertyGet(zfs_handle_t *zhp, zfs_prop_t prop, zprop_source_t *src, char *statbuf, size_t statlen, bool literalNotFriendly)
{
	import std.format:format;
	char[4096] propBuf;
	auto result = zfs_prop_get(zhp, prop, propBuf.ptr, probBuf.sizeof, src, statbuf, statlen, literalNotFriendly ? 1 : 0);

libzfs_handle_t* libZfsHandle;

enum ZfsSource
{
	local = ZPROP_SRC_LOCAL,
	default_ = ZPROP_SRC_DEFAULT,
	inherited = ZPROP_SRC_INHERITED,
	received = ZPROP_SRC_RECEIVED,
	temporary = ZPROP_SRC_TEMPORARY,
	none = ZPROP_SRC_NONE,
}

foreach(source;sources)
	cb.cb_sources |= source.to!int;


enum ZfsType
{
	filesystem = ZFS_TYPE_FILESYSTEM,
	volume = ZFS_TYPE_VOLUME,
	snapshot = ZFS_TYPE_SNAPSHOT,
	bookmark = ZFS_TYPE_BOOKMARK,
	pool = ZFS_TYPE_POOL,
	all = ZFS_TYPE_DATASET | ZFS_TYPE_BOOKMARK,
}

flags &= ~ZFS_ITER_PROP_LISTSNAPS;
foreach(type;argsTypes)
	types |= type.to!int;
	



@SILdoc(`This function takes the raw DSL properties, and filters out the user-defined properties into a separate nvlist.`)
nvlist_t* filterUserProperties(zfs_handle_t *zhp, nvlist_t *props)
{
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	nvpair_t *elem;
	nvlist_t *propval;
	nvlist_t *nvl;

	enforce(nvlist_alloc(&nvl, NV_UNIQUE_NAME, 0) ==0, "out of memory");
	elem = null;
	while ((elem = nvlist_next_nvpair(props, elem)) !is null) {
		if (!zfs_prop_user(nvpair_name(elem)))
			continue;

		enforce(nvpair_value_nvlist(elem, &propval) == 0);
		if (nvlist_add_nvlist(nvl, nvpair_name(elem), propval) != 0) {
			nvlist_free(nvl);
			no_memory(hdl);
			return null;
		}
	}

	return nvl;
}

zpool_handle_t* addHandle(zfs_handle_t *zhp, string poolName)
{
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	zpool_handle_t *zph;

	if ((zph = zpool_open_canfail(hdl, poolName)) !is null) {
		if (hdl.libzfs_pool_handles !is null)
			zph.zpool_next = hdl.libzfs_pool_handles;
		hdl.libzfs_pool_handles = zph;
	}
	return (zph);
}

zpool_handle_t* zpoolFindHandle(zfs_handle_t *zhp, string poolName,int len)
{
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	zpool_handle_t *zph = hdl.libzfs_pool_handles;

	while ((zph !is null) &&
	    (strncmp(pool_name, zpool_get_name(zph), len) != 0))
		zph = zph.zpool_next;
	return (zph);
}

@SILdoc(`Returns a handle to the pool that contains the provided dataset.  If a handle to that pool already exists then that handle is returned. Otherwise, a new handle is created and added to the list of handles.`)
zpool_handle_t* zpoolHandle(zfs_handle_t *zhp)
{
	string poolName;
	int len;
	zpool_handle_t *zph;

	len = strcspn(zhp.zfs_name, "/@#") + 1;
	pool_name = zfs_alloc(zhp.zfs_hdl, len);
	(void) strlcpy(pool_name, zhp.zfs_name, len);

	zph = zpool_find_handle(zhp, pool_name, len);
	if (zph is null)
		zph = zpool_add_handle(zhp, pool_name);

	free(pool_name);
	return (zph);
}

void zpoolFreeHandles(libzfs_handle_t *hdl)
{
	zpool_handle_t *next, *zph = hdl.libzfs_pool_handles;

	while (zph !is null) {
		next = zph.zpool_next;
		zpool_close(zph);
		zph = next;
	}
	hdl.libzfs_pool_handles = null;
}

// Utility function to gather stats (objset and zpl) for the given object.
int getStatsIoctl(zfs_handle_t *zhp, zfs_cmd_t *zc)
{
	libzfs_handle_t *hdl = zhp.zfs_hdl;

	(void) strlcpy(zc.zc_name, zhp.zfs_name, sizeof (zc.zc_name));

	while (ioctl(hdl.libzfs_fd, ZFS_IOC_OBJSET_STATS, zc) != 0) {
		if (errno == ENOMEM) {
			if (zcmd_expand_dst_nvlist(hdl, zc) != 0) {
				return (-1);
			}
		} else {
			return (-1);
		}
	}
	return (0);
}

// Utility function to get the received properties of the given object.
int getReceivedPropertiesIoCtl(zfs_handle_t *zhp)
{
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	nvlist_t *recvdprops;
	zfs_cmd_t zc = {"\0"};
	int err;

	if (zcmd_alloc_dst_nvlist(hdl, &zc, 0) != 0)
		return (-1);

	(void) strlcpy(zc.zc_name, zhp.zfs_name, sizeof (zc.zc_name));

	while (ioctl(hdl.libzfs_fd, ZFS_IOC_OBJSET_RECVD_PROPS, &zc) != 0) {
		if (errno == ENOMEM) {
			if (zcmd_expand_dst_nvlist(hdl, &zc) != 0) {
				return (-1);
			}
		} else {
			zcmd_free_nvlists(&zc);
			return (-1);
		}
	}

	err = zcmd_read_dst_nvlist(zhp.zfs_hdl, &zc, &recvdprops);
	zcmd_free_nvlists(&zc);
	if (err != 0)
		return (-1);

	nvlist_free(zhp.zfs_recvd_props);
	zhp.zfs_recvd_props = recvdprops;

	return (0);
}

int putStatsZhdl(zfs_handle_t *zhp, zfs_cmd_t *zc)
{
	nvlist_t *allprops, *userprops;

	zhp.zfs_dmustats = zc.zc_objset_stats; /* structure assignment */

	if (zcmd_read_dst_nvlist(zhp.zfs_hdl, zc, &allprops) != 0) {
		return (-1);
	}

	/*
	 * XXX Why do we store the user props separately, in addition to
	 * storing them in zfs_props?
	 */
	if ((userprops = process_user_props(zhp, allprops)) is null) {
		nvlist_free(allprops);
		return (-1);
	}

	nvlist_free(zhp.zfs_props);
	nvlist_free(zhp.zfs_user_props);

	zhp.zfs_props = allprops;
	zhp.zfs_user_props = userprops;

	return (0);
}

int getStats(zfs_handle_t *zhp)
{
	int rc = 0;
	zfs_cmd_t zc = {"\0"};

	if (zcmd_alloc_dst_nvlist(zhp.zfs_hdl, &zc, 0) != 0)
		return (-1);
	if (get_stats_ioctl(zhp, &zc) != 0)
		rc = -1;
	else if (put_stats_zhdl(zhp, &zc) != 0)
		rc = -1;
	zcmd_free_nvlists(&zc);
	return (rc);
}

// Refresh the properties currently stored in the handle.
void refreshProperties(zfs_handle_t *zhp)
{
	get_stats(zhp);
}

// Makes a handle from the given dataset name.  Used by zfs_open() and  zfs_iter_* to create child handles on the fly.
int makeDatasetHandleCommon(zfs_handle_t *zhp, zfs_cmd_t *zc)
{
	enforce(put_stats_zhdl(zhp, zc) ==0);
	// We've managed to open the dataset and gather statistics.  Determine the high-level type.
	if (zhp.zfs_dmustats.dds_type == DMU_OST_ZVOL)
		zhp.zfs_head_type = ZFS_TYPE_VOLUME;
	else if (zhp.zfs_dmustats.dds_type == DMU_OST_ZFS)
		zhp.zfs_head_type = ZFS_TYPE_FILESYSTEM;
	else if (zhp.zfs_dmustats.dds_type == DMU_OST_OTHER)
		return (-1);
	else
		abort();

	if (zhp.zfs_dmustats.dds_is_snapshot)
		zhp.zfs_type = ZFS_TYPE_SNAPSHOT;
	else if (zhp.zfs_dmustats.dds_type == DMU_OST_ZVOL)
		zhp.zfs_type = ZFS_TYPE_VOLUME;
	else if (zhp.zfs_dmustats.dds_type == DMU_OST_ZFS)
		zhp.zfs_type = ZFS_TYPE_FILESYSTEM;
	else
		abort();	/* we should never see any other types */

	if ((zhp.zpool_hdl = zpool_handle(zhp)) is null)
		return (-1);

	return (0);
}

zfs_handle_t* makeDatasetHandle(string path)
{
	libzfs_handle_t* hdl = libZfsHandle;
	zfs_cmd_t zc = {"\0"};

	zfs_handle_t *zhp = calloc(1, zfs_handle_t.sizeof);
	enforce(zhp !is null, "memory allocation");

	zhp.zfs_hdl = hdl;
	(void) strlcpy(zhp.zfs_name, path, sizeof (zhp.zfs_name));
	if (zcmd_alloc_dst_nvlist(hdl, &zc, 0) != 0) {
		free(zhp);
		return null;
	}
	if (get_stats_ioctl(zhp, &zc) == -1) {
		zcmd_free_nvlists(&zc);
		free(zhp);
		return null;
	}
	if (make_dataset_handle_common(zhp, &zc) == -1) {
		free(zhp);
		zhp = null;
	}
	zcmd_free_nvlists(&zc);
	return (zhp);
}

zfs_handle_t* makeDatasetHandleZC(zfs_cmd_t *zc)
{
	libzfs_handle_t* hdl = libZfsHandle;
	zfs_handle_t *zhp = calloc(1, sizeof (zfs_handle_t));
	enforce(zhp !is null, "memory allocation");
	zhp.zfs_hdl = hdl;
	(void) strlcpy(zhp.zfs_name, zc.zc_name, sizeof (zhp.zfs_name));
	if (make_dataset_handle_common(zhp, zc) == -1) {
		free(zhp);
		return null;
	}
	return (zhp);
}

zfs_handle_t * makeDatasetSimpleHandleZC(zfs_handle_t *pzhp, zfs_cmd_t *zc)
{
	zfs_handle_t *zhp = calloc(1, sizeof (zfs_handle_t));
	enforce(zhp !is null, "memory allocation");
	zhp.zfs_hdl = pzhp.zfs_hdl;
	(void) strlcpy(zhp.zfs_name, zc.zc_name, sizeof (zhp.zfs_name));
	zhp.zfs_head_type = pzhp.zfs_type;
	zhp.zfs_type = ZFS_TYPE_SNAPSHOT;
	zhp.zpool_hdl = zpool_handle(zhp);
	return (zhp);
}

zfs_handle_t* zfsHandleDup(zfs_handle_t *zhp_orig)
{
	zfs_handle_t *zhp = calloc(1, sizeof (zfs_handle_t));
	enforce(zhp !is null, "memory allocation");
	zhp.zfs_hdl = zhp_orig.zfs_hdl;
	zhp.zpool_hdl = zhp_orig.zpool_hdl;
	(void) strlcpy(zhp.zfs_name, zhp_orig.zfs_name,
	    sizeof (zhp.zfs_name));
	zhp.zfs_type = zhp_orig.zfs_type;
	zhp.zfs_head_type = zhp_orig.zfs_head_type;
	zhp.zfs_dmustats = zhp_orig.zfs_dmustats;
	if (zhp_orig.zfs_props !is null) {
		if (nvlist_dup(zhp_orig.zfs_props, &zhp.zfs_props, 0) != 0) {
			(void) no_memory(zhp.zfs_hdl);
			zfs_close(zhp);
			return null;
		}
	}
	if (zhp_orig.zfs_user_props !is null) {
		if (nvlist_dup(zhp_orig.zfs_user_props,
		    &zhp.zfs_user_props, 0) != 0) {
			(void) no_memory(zhp.zfs_hdl);
			zfs_close(zhp);
			return null;
		}
	}
	if (zhp_orig.zfs_recvd_props !is null) {
		if (nvlist_dup(zhp_orig.zfs_recvd_props,
		    &zhp.zfs_recvd_props, 0)) {
			(void) no_memory(zhp.zfs_hdl);
			zfs_close(zhp);
			return null;
		}
	}
	zhp.zfs_mntcheck = zhp_orig.zfs_mntcheck;
	if (zhp_orig.zfs_mntopts !is null) {
		zhp.zfs_mntopts = zfs_strdup(zhp_orig.zfs_hdl,
		    zhp_orig.zfs_mntopts);
	}
	zhp.zfs_props_table = zhp_orig.zfs_props_table;
	return (zhp);
}


@SILdoc(`Opens the given snapshot, bookmark, filesystem, or volume.   The 'types' argument is a mask of acceptable types.  The function will print an appropriate error message and return null if it can't be opened.`)
zfs_handle_t* open(string path, int types)
{
	libzfs_handle_t* hdl = libZfsHandle;
	zfs_handle_t *zhp;

	// Validate the name before we even try to open it.
	enforce(zfs_validate_name(hdl, path, types, B_FALSE), format!"cannot open %s: invalid name"(path));

	// Bookmarks needs to be handled separately.
	bool isBookmark = path.canFind("#");
	if (!isBookmark)
	{
		 // Try to get stats for the dataset, which will tell us if it exists.
		enforce(((zhp = make_dataset_handle(hdl, path)) !is null),format!"dataset %s does not exist"(path));
	} else {
		auto i = path.indexOf("#");
		enforce(i > -1, "internal error extracting parent data set for bookmark " ~ path);
		auto dsname = path[0 .. i];

		zfs_handle_t *pzhp;
		zfs_open_bookmarks_cb_data cb_data = {path, null};

		// Create handle for the parent dataset.
		enforce((pzhp = make_dataset_handle(hdl, dsname)) !is null,format!"unable to create handle for parent of %s"(path));
		scope(exit)
			zfs_close(pzhp);	
		// Iterate bookmarks to find the right one.
		errno = 0;
		if ((zfs_iter_bookmarks(pzhp, zfs_open_bookmarks_cb, &cb_data) == 0) && (cb_data.zhp is null))
		{
			(void) zfs_error(hdl, EZFS_NOENT, errbuf);
			return null;
		}
		if (cb_data.zhp is null) {
			zfs_standard_error(hdl, errno, errbuf);
			return null;
		}
		zhp = cb_data.zhp;
	}

	if (!(types & zhp.zfs_type)) {
		zfs_error(hdl, EZFS_BADTYPE, errbuf);
		zfs_close(zhp);
		return null;
	}

	return zhp;
}


@SILdoc(`Release a ZFS handle.  Nothing to do but free the associated memory.`)
void close(zfs_handle_t *zhp)
{
	if (zhp.zfs_mntopts)
		free(zhp.zfs_mntopts);
	nvlist_free(zhp.zfs_props);
	nvlist_free(zhp.zfs_user_props);
	nvlist_free(zhp.zfs_recvd_props);
	free(zhp);
}

struct mnttab_node_t
{
	mnttab mtn_mt;
	avl_node_t mtn_node;
}

int libzfs_mnttab_cache_compare(const void *arg1, const void *arg2)
{
	const mnttab_node_t *mtn1 = (const mnttab_node_t *)arg1;
	const mnttab_node_t *mtn2 = (const mnttab_node_t *)arg2;
	int rv;

	rv = strcmp(mtn1.mtn_mt.mnt_special, mtn2.mtn_mt.mnt_special);

	return (AVL_ISIGN(rv));
}

void mountTableInit(libzfs_handle_t *hdl)
{
	pthread_mutex_init(&hdl.libzfs_mnttab_cache_lock, null);
	assert(avl_numnodes(&hdl.libzfs_mnttab_cache) == 0);
	avl_create(&hdl.libzfs_mnttab_cache, libzfs_mnttab_cache_compare, sizeof (mnttab_node_t), offsetof(mnttab_node_t, mtn_node));
}

int mountTableUpdate()
{
	libzfs_handle_t* hdl = libZfsHandle;
	struct mnttab entry;

	// Reopen MNTTAB to prevent reading stale data from open file
	if (freopen(MNTTAB, "r", hdl.libzfs_mnttab) is null)
		return (ENOENT);

	while (getmntent(hdl.libzfs_mnttab, &entry) == 0)
	{
		mnttab_node_t *mtn;
		avl_index_t where;

		if (strcmp(entry.mnt_fstype, MNTTYPE_ZFS) != 0)
			continue;

		mtn = zfs_alloc(hdl, sizeof (mnttab_node_t));
		mtn.mtn_mt.mnt_special = zfs_strdup(hdl, entry.mnt_special);
		mtn.mtn_mt.mnt_mountp = zfs_strdup(hdl, entry.mnt_mountp);
		mtn.mtn_mt.mnt_fstype = zfs_strdup(hdl, entry.mnt_fstype);
		mtn.mtn_mt.mnt_mntopts = zfs_strdup(hdl, entry.mnt_mntopts);

		/* Exclude duplicate mounts */
		if (avl_find(&hdl.libzfs_mnttab_cache, mtn, &where) !is null) {
			free(mtn.mtn_mt.mnt_special);
			free(mtn.mtn_mt.mnt_mountp);
			free(mtn.mtn_mt.mnt_fstype);
			free(mtn.mtn_mt.mnt_mntopts);
			free(mtn);
			continue;
		}

		avl_add(&hdl.libzfs_mnttab_cache, mtn);
	}

	return (0);
}

void
libzfs_mnttab_fini(libzfs_handle_t *hdl)
{
	void *cookie = null;
	mnttab_node_t *mtn;

	while ((mtn = avl_destroy_nodes(&hdl.libzfs_mnttab_cache, &cookie))
	    !is null) {
		free(mtn.mtn_mt.mnt_special);
		free(mtn.mtn_mt.mnt_mountp);
		free(mtn.mtn_mt.mnt_fstype);
		free(mtn.mtn_mt.mnt_mntopts);
		free(mtn);
	}
	avl_destroy(&hdl.libzfs_mnttab_cache);
	(void) pthread_mutex_destroy(&hdl.libzfs_mnttab_cache_lock);
}

void
libzfs_mnttab_cache(libzfs_handle_t *hdl, boolean_t enable)
{
	hdl.libzfs_mnttab_enable = enable;
}

int
libzfs_mnttab_find(libzfs_handle_t *hdl, const char *fsname,
    struct mnttab *entry)
{
	mnttab_node_t find;
	mnttab_node_t *mtn;
	int ret = ENOENT;

	if (!hdl.libzfs_mnttab_enable) {
		struct mnttab srch = { 0 };

		if (avl_numnodes(&hdl.libzfs_mnttab_cache))
			libzfs_mnttab_fini(hdl);

		/* Reopen MNTTAB to prevent reading stale data from open file */
		if (freopen(MNTTAB, "r", hdl.libzfs_mnttab) is null)
			return (ENOENT);

		srch.mnt_special = (char *)fsname;
		srch.mnt_fstype = MNTTYPE_ZFS;
		if (getmntany(hdl.libzfs_mnttab, entry, &srch) == 0)
			return (0);
		else
			return (ENOENT);
	}

	pthread_mutex_lock(&hdl.libzfs_mnttab_cache_lock);
	if (avl_numnodes(&hdl.libzfs_mnttab_cache) == 0) {
		int error;

		if ((error = libzfs_mnttab_update(hdl)) != 0) {
			pthread_mutex_unlock(&hdl.libzfs_mnttab_cache_lock);
			return (error);
		}
	}

	find.mtn_mt.mnt_special = (char *)fsname;
	mtn = avl_find(&hdl.libzfs_mnttab_cache, &find, null);
	if (mtn) {
		*entry = mtn.mtn_mt;
		ret = 0;
	}
	pthread_mutex_unlock(&hdl.libzfs_mnttab_cache_lock);
	return (ret);
}

void mountTableAdd(string special, string mountp, string mntopts)
{
	libzfs_handle_t* hdl = libZfsHandle;
	mnttab_node_t *mtn;

	pthread_mutex_lock(&hdl.libzfs_mnttab_cache_lock);
	if (avl_numnodes(&hdl.libzfs_mnttab_cache) != 0)
	{
		mtn = zfs_alloc(hdl, sizeof (mnttab_node_t));
		mtn.mtn_mt.mnt_special = zfs_strdup(hdl, special);
		mtn.mtn_mt.mnt_mountp = zfs_strdup(hdl, mountp);
		mtn.mtn_mt.mnt_fstype = zfs_strdup(hdl, MNTTYPE_ZFS);
		mtn.mtn_mt.mnt_mntopts = zfs_strdup(hdl, mntopts);
		// Another thread may have already added this entry  via libzfs_mnttab_update. If so we should skip it.
		if (avl_find(&hdl.libzfs_mnttab_cache, mtn, null) !is null)
			free(mtn);
		else
			avl_add(&hdl.libzfs_mnttab_cache, mtn);
	}
	pthread_mutex_unlock(&hdl.libzfs_mnttab_cache_lock);
}

void mountTableRemove(libzfs_handle_t *hdl, const char *fsname)
{
	mnttab_node_t find;
	mnttab_node_t *ret;

	pthread_mutex_lock(&hdl.libzfs_mnttab_cache_lock);
	find.mtn_mt.mnt_special = (char *)fsname;
	if ((ret = avl_find(&hdl.libzfs_mnttab_cache, (void *)&find, null)) !is null)
	{
		avl_remove(&hdl.libzfs_mnttab_cache, ret);
		free(ret.mtn_mt.mnt_special);
		free(ret.mtn_mt.mnt_mountp);
		free(ret.mtn_mt.mnt_fstype);
		free(ret.mtn_mt.mnt_mntopts);
		free(ret);
	}
	pthread_mutex_unlock(&hdl.libzfs_mnttab_cache_lock);
}

int spaVersion(zfs_handle_t *zhp)
{
	int ret;
	zpool_handle_t *zpool_handle = zhp.zpool_hdl;
	enforce(zpool_handle !is null, "error getting zpool handle");
	ret = zpool_get_prop_int(zpool_handle, ZPOOL_PROP_VERSION, null);
	return ret;
}

@SILdoc(`The choice of reservation property depends on the SPA version.`)
zfs_prop_t whichReservationProperty(zfs_handle_t *zhp)
{
	int spa_version = spaVersion(zhp);
	return (spa_version >= SPA_VERSION_REFRESERVATION) ?  ZFS_PROP_REFRESERVATION : ZFS_PROP_RESERVATION;
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

void addSyntheticReservation(zfs_handle_t *zhp, nvlist_t *nvl)
{
	ulong old_volsize;
	ulong new_volsize;
	ulong old_reservation;
	ulong new_reservation;
	zfs_prop_t resv_prop;
	nvlist_t *props;

	/*
	 * If this is an existing volume, and someone is setting the volsize,
	 * make sure that it matches the reservation, or add it if necessary.
	 */
	old_volsize = zfs_prop_get_int(zhp, ZFS_PROP_VOLSIZE);
	if (zfs_which_resv_prop(zhp, &resv_prop) < 0)
		return (-1);
	old_reservation = zfs_prop_get_int(zhp, resv_prop);

	props = fnvlist_alloc();
	fnvlist_add_uint64(props, zfs_prop_to_name(ZFS_PROP_VOLBLOCKSIZE),
	    zfs_prop_get_int(zhp, ZFS_PROP_VOLBLOCKSIZE));

	if ((zvol_volsize_to_reservation(old_volsize, props) !=
	    old_reservation) || nvlist_exists(nvl,
	    zfs_prop_to_name(resv_prop))) {
		fnvlist_free(props);
		return (0);
	}
	if (nvlist_lookup_uint64(nvl, zfs_prop_to_name(ZFS_PROP_VOLSIZE),
	    &new_volsize) != 0) {
		fnvlist_free(props);
		return (-1);
	}
	new_reservation = zvol_volsize_to_reservation(new_volsize, props);
	fnvlist_free(props);

	if (nvlist_add_uint64(nvl, zfs_prop_to_name(resv_prop),
	    new_reservation) != 0) {
		(void) no_memory(zhp.zfs_hdl);
		return (-1);
	}
	return (1);
}

/*
 * Helper for 'zfs {set|clone} refreservation=auto'.  Must be called after
 * zfs_valid_proplist(), as it is what sets the UINT64_MAX sentinal value.
 * Return codes must match zfs_add_synthetic_resv().
 */
static int
zfs_fix_auto_resv(zfs_handle_t *zhp, nvlist_t *nvl)
{
	ulong volsize;
	ulong resvsize;
	zfs_prop_t prop;
	nvlist_t *props;

	if (!ZFS_IS_VOLUME(zhp)) {
		return (0);
	}

	if (zfs_which_resv_prop(zhp, &prop) != 0) {
		return (-1);
	}

	if (prop != ZFS_PROP_REFRESERVATION) {
		return (0);
	}

	if (nvlist_lookup_uint64(nvl, zfs_prop_to_name(prop), &resvsize) != 0) {
		/* No value being set, so it can't be "auto" */
		return (0);
	}
	if (resvsize != UINT64_MAX) {
		/* Being set to a value other than "auto" */
		return (0);
	}

	props = fnvlist_alloc();

	fnvlist_add_uint64(props, zfs_prop_to_name(ZFS_PROP_VOLBLOCKSIZE),
	    zfs_prop_get_int(zhp, ZFS_PROP_VOLBLOCKSIZE));

	if (nvlist_lookup_uint64(nvl, zfs_prop_to_name(ZFS_PROP_VOLSIZE),
	    &volsize) != 0) {
		volsize = zfs_prop_get_int(zhp, ZFS_PROP_VOLSIZE);
	}

	resvsize = zvol_volsize_to_reservation(volsize, props);
	fnvlist_free(props);

	(void) nvlist_remove_all(nvl, zfs_prop_to_name(prop));
	if (nvlist_add_uint64(nvl, zfs_prop_to_name(prop), resvsize) != 0) {
		(void) no_memory(zhp.zfs_hdl);
		return (-1);
	}
	return (1);
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


@SILdoc(`Given a property name and value, set the property for the given dataset.`)
void setDatasetProperty(zfs_handle_t *zhp, string propertyName, string propertyValue)
{
	int ret = -1;
	char errbuf[1024];
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	nvlist_t *nvl = null;

	(void) snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN, "cannot set property for '%s'"), zhp.zfs_name);

	if (nvlist_alloc(&nvl, NV_UNIQUE_NAME, 0) != 0 || nvlist_add_string(nvl, propname, propval) != 0)
	{
		(void) no_memory(hdl);
		goto error;
	}
	ret = zfs_prop_set_list(zhp, nvl);

error:
	nvlist_free(nvl);
	return (ret);
}



@SILdoc(`Given an nvlist of property names and values, set the properties for the given dataset`)
void setDatasetProperties(zfs_handle_t *zhp, Variable[string] properties)
{
	zfs_cmd_t zc = {"\0"};
	int ret = -1;
	prop_changelist_t **cls = null;
	int cl_idx;
	char errbuf[1024];
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	nvlist_t *nvl;
	int nvl_len = 0;
	int added_resv = 0;
	zfs_prop_t prop = 0;
	nvpair_t *elem;

	(void) snprintf(errbuf, sizeof (errbuf),
	    dgettext(TEXT_DOMAIN, "cannot set property for '%s'"),
	    zhp.zfs_name);

	if ((nvl = zfs_valid_proplist(hdl, zhp.zfs_type, props,
	    zfs_prop_get_int(zhp, ZFS_PROP_ZONED), zhp, zhp.zpool_hdl,
	    B_FALSE, errbuf)) is null)
		goto error;

	/*
	 * We have to check for any extra properties which need to be added
	 * before computing the length of the nvlist.
	 */
	for (elem = nvlist_next_nvpair(nvl, null);
	    elem !is null;
	    elem = nvlist_next_nvpair(nvl, elem)) {
		if (zfs_name_to_prop(nvpair_name(elem)) == ZFS_PROP_VOLSIZE &&
		    (added_resv = zfs_add_synthetic_resv(zhp, nvl)) == -1) {
			goto error;
		}
	}

	if (added_resv != 1 &&
	    (added_resv = zfs_fix_auto_resv(zhp, nvl)) == -1) {
		goto error;
	}

	/*
	 * Check how many properties we're setting and allocate an array to
	 * store changelist pointers for postfix().
	 */
	for (elem = nvlist_next_nvpair(nvl, null);
	    elem !is null;
	    elem = nvlist_next_nvpair(nvl, elem))
		nvl_len++;
	if ((cls = calloc(nvl_len, sizeof (prop_changelist_t *))) is null)
		goto error;

	cl_idx = 0;
	for (elem = nvlist_next_nvpair(nvl, null);
	    elem !is null;
	    elem = nvlist_next_nvpair(nvl, elem)) {

		prop = zfs_name_to_prop(nvpair_name(elem));

		assert(cl_idx < nvl_len);
		/*
		 * We don't want to unmount & remount the dataset when changing
		 * its canmount property to 'on' or 'noauto'.  We only use
		 * the changelist logic to unmount when setting canmount=off.
		 */
		if (prop != ZFS_PROP_CANMOUNT ||
		    (fnvpair_value_uint64(elem) == ZFS_CANMOUNT_OFF &&
		    zfs_is_mounted(zhp, null))) {
			cls[cl_idx] = changelist_gather(zhp, prop, 0, 0);
			if (cls[cl_idx] is null)
				goto error;
		}

		if (prop == ZFS_PROP_MOUNTPOINT &&
		    changelist_haszonedchild(cls[cl_idx])) {
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "child dataset with inherited mountpoint is used "
			    "in a non-global zone"));
			ret = zfs_error(hdl, EZFS_ZONED, errbuf);
			goto error;
		}

		if (cls[cl_idx] !is null &&
		    (ret = changelist_prefix(cls[cl_idx])) != 0)
			goto error;

		cl_idx++;
	}
	assert(cl_idx == nvl_len);

	/*
	 * Execute the corresponding ioctl() to set this list of properties.
	 */
	(void) strlcpy(zc.zc_name, zhp.zfs_name, sizeof (zc.zc_name));

	if ((ret = zcmd_write_src_nvlist(hdl, &zc, nvl)) != 0 ||
	    (ret = zcmd_alloc_dst_nvlist(hdl, &zc, 0)) != 0)
		goto error;

	ret = zfs_ioctl(hdl, ZFS_IOC_SET_PROP, &zc);

	if (ret != 0) {
		if (zc.zc_nvlist_dst_filled == B_FALSE) {
			(void) zfs_standard_error(hdl, errno, errbuf);
			goto error;
		}

		/* Get the list of unset properties back and report them. */
		nvlist_t *errorprops = null;
		if (zcmd_read_dst_nvlist(hdl, &zc, &errorprops) != 0)
			goto error;
		for (nvpair_t *elem = nvlist_next_nvpair(errorprops, null);
		    elem !is null;
		    elem = nvlist_next_nvpair(errorprops, elem)) {
			prop = zfs_name_to_prop(nvpair_name(elem));
			zfs_setprop_error(hdl, prop, errno, errbuf);
		}
		nvlist_free(errorprops);

		if (added_resv && errno == ENOSPC) {
			/* clean up the volsize property we tried to set */
			ulong old_volsize = zfs_prop_get_int(zhp,
			    ZFS_PROP_VOLSIZE);
			nvlist_free(nvl);
			nvl = null;
			zcmd_free_nvlists(&zc);

			if (nvlist_alloc(&nvl, NV_UNIQUE_NAME, 0) != 0)
				goto error;
			if (nvlist_add_uint64(nvl,
			    zfs_prop_to_name(ZFS_PROP_VOLSIZE),
			    old_volsize) != 0)
				goto error;
			if (zcmd_write_src_nvlist(hdl, &zc, nvl) != 0)
				goto error;
			(void) zfs_ioctl(hdl, ZFS_IOC_SET_PROP, &zc);
		}
	} else {
		for (cl_idx = 0; cl_idx < nvl_len; cl_idx++) {
			if (cls[cl_idx] !is null) {
				int clp_err = changelist_postfix(cls[cl_idx]);
				if (clp_err != 0)
					ret = clp_err;
			}
		}

		if (ret == 0) {
			/*
			 * Refresh the statistics so the new property
			 * value is reflected.
			 */
			(void) get_stats(zhp);

			/*
			 * Remount the filesystem to propagate the change
			 * if one of the options handled by the generic
			 * Linux namespace layer has been modified.
			 */
			if (zfs_is_namespace_prop(prop) &&
			    zfs_is_mounted(zhp, null))
				ret = zfs_mount(zhp, MNTOPT_REMOUNT, 0);
		}
	}

error:
	nvlist_free(nvl);
	zcmd_free_nvlists(&zc);
	if (cls !is null) {
		for (cl_idx = 0; cl_idx < nvl_len; cl_idx++) {
			if (cls[cl_idx] !is null)
				changelist_free(cls[cl_idx]);
		}
		free(cls);
	}
	return (ret);
}

/*
 * Given a property, inherit the value from the parent dataset, or if received
 * is TRUE, revert to the received value, if any.
 */
void propertyInherit(zfs_handle_t *zhp, string propertyName, bool received)
{
	zfs_cmd_t zc = {"\0"};
	int ret;
	prop_changelist_t *cl;
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	zfs_prop_t prop;

	auto errbuf = format!"cannot inherit %s for '%s'"(propertyName, zhp.zfs_name);
	zc.zc_cookie = received;
	if ((prop = zfs_name_to_prop(propname)) == ZPROP_INVAL)
	{
		 // For user properties, the amount of work we have to do is very small, so just do it here.
		if (!zfs_prop_user(propname))
		{
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "invalid property"));
			return (zfs_error(hdl, EZFS_BADPROP, errbuf));
		}

		strlcpy(zc.zc_name, zhp.zfs_name, sizeof (zc.zc_name));
		strlcpy(zc.zc_value, propname, sizeof (zc.zc_value));

		if (zfs_ioctl(zhp.zfs_hdl, ZFS_IOC_INHERIT_PROP, &zc) != 0)
			return (zfs_standard_error(hdl, errno, errbuf));
		return (0);
	}

	// Verify that this property is inheritable.
	if (zfs_prop_readonly(prop))
		return (zfs_error(hdl, EZFS_PROPREADONLY, errbuf));

	if (!zfs_prop_inheritable(prop) && !received)
		return (zfs_error(hdl, EZFS_PROPNONINHERIT, errbuf));

	 // Check to see if the value applies to this type
	if (!zfs_prop_valid_for_type(prop, zhp.zfs_type, B_FALSE))
		return (zfs_error(hdl, EZFS_PROPTYPE, errbuf));

	// Normalize the name, to get rid of shorthand abbreviations.
	propname = zfs_prop_to_name(prop);
	strlcpy(zc.zc_name, zhp.zfs_name, sizeof (zc.zc_name));
	strlcpy(zc.zc_value, propname, sizeof (zc.zc_value));

	if (prop == ZFS_PROP_MOUNTPOINT && getzoneid() == GLOBAL_ZONEID && zfs_prop_get_int(zhp, ZFS_PROP_ZONED))
	{
		zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "dataset is used in a non-global zone"));
		return (zfs_error(hdl, EZFS_ZONED, errbuf));
	}

	// Determine datasets which will be affected by this change, if any.
	if ((cl = changelist_gather(zhp, prop, 0, 0)) is null)
		return (-1);

	if (prop == ZFS_PROP_MOUNTPOINT && changelist_haszonedchild(cl))
	{
		zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "child dataset with inherited mountpoint is used in a non-global zone"));
		ret = zfs_error(hdl, EZFS_ZONED, errbuf);
		goto error;
	}

	if ((ret = changelist_prefix(cl)) != 0)
		goto error;

	if ((ret = zfs_ioctl(zhp.zfs_hdl, ZFS_IOC_INHERIT_PROP, &zc)) != 0) {
		return (zfs_standard_error(hdl, errno, errbuf));
	} else {

		if ((ret = changelist_postfix(cl)) != 0)
			goto error;

		 // Refresh the statistics so the new property is reflected.
		get_stats(zhp);

		 // Remount the filesystem to propagate the change if one of the options handled by the generic Linux namespace layer has been modified.
		if (zfs_is_namespace_prop(prop) && zfs_is_mounted(zhp, null)) ret = zfs_mount(zhp, MNTOPT_REMOUNT, 0);
	}

error:
	changelist_free(cl);
	return (ret);
}

// True DSL properties are stored in an nvlist.  The following two functions extract them appropriately.
auto getPropertyT(T)(zfs_handle_t *zhp, zfs_prop_t prop)
if (is(T==ulong))
{
	string source;
	nvlist_t *nv;
	ulong value;

	if (nvlist_lookup_nvlist(zhp.zfs_props, zfs_prop_to_name(prop), &nv) == 0)
	{
		enforce(nvlist_lookup_uint64(nv, ZPROP_VALUE, &value) == 0);
		nvlist_lookup_string(nv, ZPROP_SOURCE, source);
	} else
	{
		enforce(!zhp.zfs_props_table || zhp.zfs_props_table[prop] == B_TRUE);
		value = zfs_prop_default_numeric(prop);
		source = "";
	}
	return tuple(value,source);
}

string getPropertyT(T)(zfs_handle_t *zhp, zfs_prop_t prop, char **source)
if (is(T==string))
{
	nvlist_t *nv;
	const char *value;
	string source;

	if (nvlist_lookup_nvlist(zhp.zfs_props, zfs_prop_to_name(prop), &nv) == 0)
	{
		value = fnvlist_lookup_string(nv, ZPROP_VALUE);
		nvlist_lookup_string(nv, ZPROP_SOURCE, source);
	} else
	{
		enforce(!zhp.zfs_props_table || zhp.zfs_props_table[prop] == B_TRUE);
		value = zfs_prop_default_string(prop);
		source = "";
	}
	return tuple(value,soruce);
}

bool isReceivedPropertiesMode(zfs_handle_t *zhp)
{
	return (zhp.zfs_props == zhp.zfs_recvd_props);
}

void setReceivedPropertiesMode(zfs_handle_t *zhp, ulong *cookie)
{
	*cookie = (ulong)(uintptr_t)zhp.zfs_props;
	zhp.zfs_props = zhp.zfs_recvd_props;
}

void unsetReceivedPropertiesMode(zfs_handle_t *zhp, ulong *cookie)
{
	zhp.zfs_props = (nvlist_t *)(uintptr_t)*cookie;
	*cookie = 0;
}


@SILdoc(`Internal function for getting a numeric property.  Both zfs_prop_get() and zfs_prop_get_int() are built using this interface.

Certain properties can be overridden using 'mount -o'.  In this case, scan the contents of the /proc/self/mounts entry, searching for the appropriate options. If they differ from the on-disk values, report the current values and mark the source "temporary".
`)
int getNumericProperty(zfs_handle_t *zhp, zfs_prop_t prop, zprop_source_t *src, char **source, ulong *val)
{
	zfs_cmd_t zc = {"\0"};
	nvlist_t *zplprops;
	mnttab mnt;
	char *mntopt_on;
	char *mntopt_off;
	bool received = zfs_is_recvd_props_mode(zhp);

	*source = null;

	// If the property is being fetched for a snapshot, check whether the property is valid for the snapshot's head dataset type.
	if (zhp.zfs_type == ZFS_TYPE_SNAPSHOT &&
	    !zfs_prop_valid_for_type(prop, zhp.zfs_head_type, B_TRUE)) {
		*val = zfs_prop_default_numeric(prop);
		return (-1);
	}

	switch (prop) with(ZfsPropertyType)
	{
		case atime:
			mntopt_on = MNTOPT_ATIME;
			mntopt_off = MNTOPT_NOATIME;
			break;

		case relatime::
			mntopt_on = MNTOPT_RELATIME;
			mntopt_off = MNTOPT_NORELATIME;
			break;

		case devices:
			mntopt_on = MNTOPT_DEVICES;
			mntopt_off = MNTOPT_NODEVICES;
			break;

		case exec:
			mntopt_on = MNTOPT_EXEC;
			mntopt_off = MNTOPT_NOEXEC;
			break;

		case readOnly:
			mntopt_on = MNTOPT_RO;
			mntopt_off = MNTOPT_RW;
			break;

		case setuid:
			mntopt_on = MNTOPT_SETUID;
			mntopt_off = MNTOPT_NOSETUID;
			break;

		case xattr:
			mntopt_on = MNTOPT_XATTR;
			mntopt_off = MNTOPT_NOXATTR;
			break;

		case nbmand:
			mntopt_on = MNTOPT_NBMAND;
			mntopt_off = MNTOPT_NONBMAND;
			break;

		default:
			break;
	}

	/*
	 * Because looking up the mount options is potentially expensive
	 * (iterating over all of /proc/self/mounts), we defer its
	 * calculation until we're looking up a property which requires
	 * its presence.
	 */
	if (!zhp.zfs_mntcheck &&
	    (mntopt_on !is null || prop == ZFS_PROP_MOUNTED)) {
		libzfs_handle_t *hdl = zhp.zfs_hdl;
		struct mnttab entry;

		if (libzfs_mnttab_find(hdl, zhp.zfs_name, &entry) == 0) {
			zhp.zfs_mntopts = zfs_strdup(hdl,
			    entry.mnt_mntopts);
			if (zhp.zfs_mntopts is null)
				return (-1);
		}

		zhp.zfs_mntcheck = B_TRUE;
	}

	if (zhp.zfs_mntopts is null)
		mnt.mnt_mntopts = "";
	else
		mnt.mnt_mntopts = zhp.zfs_mntopts;

	switch (prop) with(ZfsPropertyType)
	{
		case atime,relatime,devices,exec,readOnly,setuid,xattr,nbmand:
			*val = getprop_uint64(zhp, prop, source);

			if (received)
				break;

			if (hasmntopt(&mnt, mntopt_on) && !*val) {
				*val = B_TRUE;
				if (src)
					*src = ZPROP_SRC_TEMPORARY;
			} else if (hasmntopt(&mnt, mntopt_off) && *val) {
				*val = B_FALSE;
				if (src)
					*src = ZPROP_SRC_TEMPORARY;
			}
			break;

		case canMount,volSize,quota,refQuota,reservation,refReservation,filesystemLimit,snapshotLimit:
		case snapshotCount:
			*val = getprop_uint64(zhp, prop, source);
			if (*source is null) {
				/* not default, must be local */
			*source = zhp.zfs_name;
			}
			break;

		case mounted:
			*val = (zhp.zfs_mntopts !is null);
			break;

		case numClones:
			*val = zhp.zfs_dmustats.dds_num_clones;
			break;

		case version_,normalize,utf8Only,case_:
			if (zcmd_alloc_dst_nvlist(zhp.zfs_hdl, &zc, 0) != 0)
				return (-1);
			(void) strlcpy(zc.zc_name, zhp.zfs_name, sizeof (zc.zc_name));
			if (zfs_ioctl(zhp.zfs_hdl, ZFS_IOC_OBJSET_ZPLPROPS, &zc)) {
				zcmd_free_nvlists(&zc);
				if (prop == ZFS_PROP_VERSION &&
					zhp.zfs_type == ZFS_TYPE_VOLUME)
					*val = zfs_prop_default_numeric(prop);
				return (-1);
			}
			if (zcmd_read_dst_nvlist(zhp.zfs_hdl, &zc, &zplprops) != 0 ||
				nvlist_lookup_uint64(zplprops, zfs_prop_to_name(prop),
				val) != 0) {
				zcmd_free_nvlists(&zc);
				return (-1);
			}
			nvlist_free(zplprops);
			zcmd_free_nvlists(&zc);
		break;

		case inconsistent:
		*val = zhp.zfs_dmustats.dds_inconsistent;
		break;

	default:
		switch (zfs_prop_get_type(prop)) {
		case PROP_TYPE_NUMBER:
		case PROP_TYPE_INDEX:
			*val = getprop_uint64(zhp, prop, source);
			/*
			 * If we tried to use a default value for a
			 * readonly property, it means that it was not
			 * present.  Note this only applies to "truly"
			 * readonly properties, not set-once properties
			 * like volblocksize.
			 */
			if (zfs_prop_readonly(prop) &&
			    !zfs_prop_setonce(prop) &&
			    *source !is null && (*source)[0] == '\0') {
				*source = null;
				return (-1);
			}
			break;

		case PROP_TYPE_STRING:
		default:
			zfs_error_aux(zhp.zfs_hdl, dgettext(TEXT_DOMAIN,
			    "cannot get non-numeric property"));
			return (zfs_error(zhp.zfs_hdl, EZFS_BADPROP,
			    dgettext(TEXT_DOMAIN, "internal error")));
		}
	}

	return (0);
}

// Calculate the source type, given the raw source string.
void getSource(zfs_handle_t *zhp, zprop_source_t *srctype, char *source, char *statbuf, size_t statlen)
{
	if (statbuf is null || srctype is null || *srctype == ZPROP_SRC_TEMPORARY) {
		return;
	}

	if (source is null) {
		*srctype = ZPROP_SRC_NONE;
	} else if (source[0] == '\0') {
		*srctype = ZPROP_SRC_DEFAULT;
	} else if (strstr(source, ZPROP_SOURCE_VAL_RECVD) !is null) {
		*srctype = ZPROP_SRC_RECEIVED;
	} else {
		if (strcmp(source, zhp.zfs_name) == 0) {
			*srctype = ZPROP_SRC_LOCAL;
		} else {
			(void) strlcpy(statbuf, source, statlen);
			*srctype = ZPROP_SRC_INHERITED;
		}
	}

}

int propertyGetReceived(zfs_handle_t *zhp, const char *propname, char *propbuf, size_t proplen, boolean_t literal)
{
	zfs_prop_t prop;
	int err = 0;

	if (zhp.zfs_recvd_props is null)
		if (get_recvd_props_ioctl(zhp) != 0)
			return (-1);

	prop = zfs_name_to_prop(propname);

	if (prop != ZPROP_INVAL) {
		ulong cookie;
		if (!nvlist_exists(zhp.zfs_recvd_props, propname))
			return (-1);
		zfs_set_recvd_props_mode(zhp, &cookie);
		err = zfs_prop_get(zhp, prop, propbuf, proplen,
		    null, null, 0, literal);
		zfs_unset_recvd_props_mode(zhp, &cookie);
	} else {
		nvlist_t *propval;
		char *recvdval;
		if (nvlist_lookup_nvlist(zhp.zfs_recvd_props,
		    propname, &propval) != 0)
			return (-1);
		verify(nvlist_lookup_string(propval, ZPROP_VALUE,
		    &recvdval) == 0);
		(void) strlcpy(propbuf, recvdval, proplen);
	}

	return (err == 0 ? 0 : -1);
}

string getClonesString(zfs_handle_t *zhp)
{
	string ret;
	nvlist_t *value;
	nvpair_t *pair;

	value = zfs_get_clones_nvl(zhp);
	enforce(value !is null, "operation failed");

	for(pair = nvlist_next_nvpair(value, null); pair !is null; pair = nvlist_next_nvpair(value, pair))
	{
		if (ret.length > 0)
			ret ~= ",";
		ret ~= nvpair_name(pair).fromCString.idup;
	}
}

struct get_clones_arg
{
	ulong numclones;
	nvlist_t *value;
	string origin;
	char[ZFS_MAX_DATASET_NAME_LEN] buf;
};

auto getClonesCallback(zfs_handle_t *zhp, void *arg)
{
	struct get_clones_arg *gca = arg;

	if (gca.numclones == 0) {
		zfs_close(zhp);
		return (0);
	}

	if (zfs_prop_get(zhp, ZFS_PROP_ORIGIN, gca.buf, sizeof (gca.buf),
	    null, null, 0, B_TRUE) != 0)
		goto out;
	if (strcmp(gca.buf, gca.origin) == 0) {
		fnvlist_add_boolean(gca.value, zfs_get_name(zhp));
		gca.numclones--;
	}

out:
	(void) zfs_iter_children(zhp, get_clones_cb, gca);
	zfs_close(zhp);
	return (0);
}

nvlist_t *
zfs_get_clones_nvl(zfs_handle_t *zhp)
{
	nvlist_t *nv, *value;

	if (nvlist_lookup_nvlist(zhp.zfs_props,
	    zfs_prop_to_name(ZFS_PROP_CLONES), &nv) != 0) {
		struct get_clones_arg gca;

		/*
		 * if this is a snapshot, then the kernel wasn't able
		 * to get the clones.  Do it by slowly iterating.
		 */
		if (zhp.zfs_type != ZFS_TYPE_SNAPSHOT)
			return (null);
		if (nvlist_alloc(&nv, NV_UNIQUE_NAME, 0) != 0)
			return (null);
		if (nvlist_alloc(&value, NV_UNIQUE_NAME, 0) != 0) {
			nvlist_free(nv);
			return (null);
		}

		gca.numclones = zfs_prop_get_int(zhp, ZFS_PROP_NUMCLONES);
		gca.value = value;
		gca.origin = zhp.zfs_name;

		if (gca.numclones != 0) {
			zfs_handle_t *root;
			char pool[ZFS_MAX_DATASET_NAME_LEN];
			char *cp = pool;

			/* get the pool name */
			(void) strlcpy(pool, zhp.zfs_name, sizeof (pool));
			(void) strsep(&cp, "/@");
			root = zfs_open(zhp.zfs_hdl, pool,
			    ZFS_TYPE_FILESYSTEM);
			if (root is null) {
				nvlist_free(nv);
				nvlist_free(value);
				return (null);
			}

			(void) get_clones_cb(root, &gca);
		}

		if (gca.numclones != 0 ||
		    nvlist_add_nvlist(nv, ZPROP_VALUE, value) != 0 ||
		    nvlist_add_nvlist(zhp.zfs_props,
		    zfs_prop_to_name(ZFS_PROP_CLONES), nv) != 0) {
			nvlist_free(nv);
			nvlist_free(value);
			return (null);
		}
		nvlist_free(nv);
		nvlist_free(value);
		verify(0 == nvlist_lookup_nvlist(zhp.zfs_props,
		    zfs_prop_to_name(ZFS_PROP_CLONES), &nv));
	}

	verify(nvlist_lookup_nvlist(nv, ZPROP_VALUE, &value) == 0);

	return (value);
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

/*
 * Retrieve a property from the given object.  If 'literal' is specified, then
 * numbers are left as exact values.  Otherwise, numbers are converted to a
 * human-readable form.
 *
 * Returns 0 on success, or -1 on error.
 */
int
zfs_prop_get(zfs_handle_t *zhp, zfs_prop_t prop, char *propbuf, size_t proplen,
    zprop_source_t *src, char *statbuf, size_t statlen, boolean_t literal)
{
	char *source = null;
	ulong val;
	const char *str;
	const char *strval;
	boolean_t received = zfs_is_recvd_props_mode(zhp);

	/*
	 * Check to see if this property applies to our object
	 */
	if (!zfs_prop_valid_for_type(prop, zhp.zfs_type, B_FALSE))
		return (-1);

	if (received && zfs_prop_readonly(prop))
		return (-1);

	if (src)
		*src = ZPROP_SRC_NONE;

	switch (prop) {
	case ZFS_PROP_CREATION:
		/*
		 * 'creation' is a time_t stored in the statistics.  We convert
		 * this into a string unless 'literal' is specified.
		 */
		{
			val = getprop_uint64(zhp, prop, &source);
			time_t time = (time_t)val;
			struct tm t;

			if (literal ||
			    localtime_r(&time, &t) is null ||
			    strftime(propbuf, proplen, "%a %b %e %k:%M %Y",
			    &t) == 0)
				(void) snprintf(propbuf, proplen, "%llu",
				    (u_longlong_t)val);
		}
		zcp_check(zhp, prop, val, null);
		break;

	case ZFS_PROP_MOUNTPOINT:
		/*
		 * Getting the precise mountpoint can be tricky.
		 *
		 *  - for 'none' or 'legacy', return those values.
		 *  - for inherited mountpoints, we want to take everything
		 *    after our ancestor and append it to the inherited value.
		 *
		 * If the pool has an alternate root, we want to prepend that
		 * root to any values we return.
		 */

		str = getprop_string(zhp, prop, &source);

		if (str[0] == '/') {
			char buf[MAXPATHLEN];
			char *root = buf;
			const char *relpath;

			/*
			 * If we inherit the mountpoint, even from a dataset
			 * with a received value, the source will be the path of
			 * the dataset we inherit from. If source is
			 * ZPROP_SOURCE_VAL_RECVD, the received value is not
			 * inherited.
			 */
			if (strcmp(source, ZPROP_SOURCE_VAL_RECVD) == 0) {
				relpath = "";
			} else {
				relpath = zhp.zfs_name + strlen(source);
				if (relpath[0] == '/')
					relpath++;
			}

			if ((zpool_get_prop(zhp.zpool_hdl,
			    ZPOOL_PROP_ALTROOT, buf, MAXPATHLEN, null,
			    B_FALSE)) || (strcmp(root, "-") == 0))
				root[0] = '\0';
			/*
			 * Special case an alternate root of '/'. This will
			 * avoid having multiple leading slashes in the
			 * mountpoint path.
			 */
			if (strcmp(root, "/") == 0)
				root++;

			/*
			 * If the mountpoint is '/' then skip over this
			 * if we are obtaining either an alternate root or
			 * an inherited mountpoint.
			 */
			if (str[1] == '\0' && (root[0] != '\0' ||
			    relpath[0] != '\0'))
				str++;

			if (relpath[0] == '\0')
				(void) snprintf(propbuf, proplen, "%s%s",
				    root, str);
			else
				(void) snprintf(propbuf, proplen, "%s%s%s%s",
				    root, str, relpath[0] == '@' ? "" : "/",
				    relpath);
		} else {
			/* 'legacy' or 'none' */
			(void) strlcpy(propbuf, str, proplen);
		}
		zcp_check(zhp, prop, 0, propbuf);
		break;

	case ZFS_PROP_ORIGIN:
		str = getprop_string(zhp, prop, &source);
		if (str is null)
			return (-1);
		(void) strlcpy(propbuf, str, proplen);
		zcp_check(zhp, prop, 0, str);
		break;

	case ZFS_PROP_CLONES:
		if (get_clones_string(zhp, propbuf, proplen) != 0)
			return (-1);
		break;

	case ZFS_PROP_QUOTA:
	case ZFS_PROP_REFQUOTA:
	case ZFS_PROP_RESERVATION:
	case ZFS_PROP_REFRESERVATION:

		if (get_numeric_property(zhp, prop, src, &source, &val) != 0)
			return (-1);
		/*
		 * If quota or reservation is 0, we translate this into 'none'
		 * (unless literal is set), and indicate that it's the default
		 * value.  Otherwise, we print the number nicely and indicate
		 * that its set locally.
		 */
		if (val == 0) {
			if (literal)
				(void) strlcpy(propbuf, "0", proplen);
			else
				(void) strlcpy(propbuf, "none", proplen);
		} else {
			if (literal)
				(void) snprintf(propbuf, proplen, "%llu",
				    (u_longlong_t)val);
			else
				zfs_nicebytes(val, propbuf, proplen);
		}
		zcp_check(zhp, prop, val, null);
		break;

	case ZFS_PROP_FILESYSTEM_LIMIT:
	case ZFS_PROP_SNAPSHOT_LIMIT:
	case ZFS_PROP_FILESYSTEM_COUNT:
	case ZFS_PROP_SNAPSHOT_COUNT:

		if (get_numeric_property(zhp, prop, src, &source, &val) != 0)
			return (-1);

		/*
		 * If limit is UINT64_MAX, we translate this into 'none' (unless
		 * literal is set), and indicate that it's the default value.
		 * Otherwise, we print the number nicely and indicate that it's
		 * set locally.
		 */
		if (literal) {
			(void) snprintf(propbuf, proplen, "%llu",
			    (u_longlong_t)val);
		} else if (val == UINT64_MAX) {
			(void) strlcpy(propbuf, "none", proplen);
		} else {
			zfs_nicenum(val, propbuf, proplen);
		}

		zcp_check(zhp, prop, val, null);
		break;

	case ZFS_PROP_REFRATIO:
	case ZFS_PROP_COMPRESSRATIO:
		if (get_numeric_property(zhp, prop, src, &source, &val) != 0)
			return (-1);
		if (literal)
			(void) snprintf(propbuf, proplen, "%llu.%02llu",
			    (u_longlong_t)(val / 100),
			    (u_longlong_t)(val % 100));
		else
			(void) snprintf(propbuf, proplen, "%llu.%02llux",
			    (u_longlong_t)(val / 100),
			    (u_longlong_t)(val % 100));
		zcp_check(zhp, prop, val, null);
		break;

	case ZFS_PROP_TYPE:
		switch (zhp.zfs_type) {
		case ZFS_TYPE_FILESYSTEM:
			str = "filesystem";
			break;
		case ZFS_TYPE_VOLUME:
			str = "volume";
			break;
		case ZFS_TYPE_SNAPSHOT:
			str = "snapshot";
			break;
		case ZFS_TYPE_BOOKMARK:
			str = "bookmark";
			break;
		default:
			abort();
		}
		(void) snprintf(propbuf, proplen, "%s", str);
		zcp_check(zhp, prop, 0, propbuf);
		break;

	case ZFS_PROP_MOUNTED:
		/*
		 * The 'mounted' property is a pseudo-property that described
		 * whether the filesystem is currently mounted.  Even though
		 * it's a boolean value, the typical values of "on" and "off"
		 * don't make sense, so we translate to "yes" and "no".
		 */
		if (get_numeric_property(zhp, ZFS_PROP_MOUNTED,
		    src, &source, &val) != 0)
			return (-1);
		if (val)
			(void) strlcpy(propbuf, "yes", proplen);
		else
			(void) strlcpy(propbuf, "no", proplen);
		break;

	case ZFS_PROP_NAME:
		/*
		 * The 'name' property is a pseudo-property derived from the
		 * dataset name.  It is presented as a real property to simplify
		 * consumers.
		 */
		(void) strlcpy(propbuf, zhp.zfs_name, proplen);
		zcp_check(zhp, prop, 0, propbuf);
		break;

	case ZFS_PROP_MLSLABEL:
		{
#ifdef HAVE_MLSLABEL
			m_label_t *new_sl = null;
			char *ascii = null;	/* human readable label */

			(void) strlcpy(propbuf,
			    getprop_string(zhp, prop, &source), proplen);

			if (literal || (strcasecmp(propbuf,
			    ZFS_MLSLABEL_DEFAULT) == 0))
				break;

			/*
			 * Try to translate the internal hex string to
			 * human-readable output.  If there are any
			 * problems just use the hex string.
			 */

			if (str_to_label(propbuf, &new_sl, MAC_LABEL,
			    L_NO_CORRECTION, null) == -1) {
				m_label_free(new_sl);
				break;
			}

			if (label_to_str(new_sl, &ascii, M_LABEL,
			    DEF_NAMES) != 0) {
				if (ascii)
					free(ascii);
				m_label_free(new_sl);
				break;
			}
			m_label_free(new_sl);

			(void) strlcpy(propbuf, ascii, proplen);
			free(ascii);
#else
			(void) strlcpy(propbuf,
			    getprop_string(zhp, prop, &source), proplen);
#endif /* HAVE_MLSLABEL */
		}
		break;

	case ZFS_PROP_GUID:
	case ZFS_PROP_CREATETXG:
	case ZFS_PROP_OBJSETID:
		/*
		 * These properties are stored as numbers, but they are
		 * identifiers.
		 * We don't want them to be pretty printed, because pretty
		 * printing mangles the ID into a truncated and useless value.
		 */
		if (get_numeric_property(zhp, prop, src, &source, &val) != 0)
			return (-1);
		(void) snprintf(propbuf, proplen, "%llu", (u_longlong_t)val);
		zcp_check(zhp, prop, val, null);
		break;

	case ZFS_PROP_REFERENCED:
	case ZFS_PROP_AVAILABLE:
	case ZFS_PROP_USED:
	case ZFS_PROP_USEDSNAP:
	case ZFS_PROP_USEDDS:
	case ZFS_PROP_USEDREFRESERV:
	case ZFS_PROP_USEDCHILD:
		if (get_numeric_property(zhp, prop, src, &source, &val) != 0)
			return (-1);
		if (literal) {
			(void) snprintf(propbuf, proplen, "%llu",
			    (u_longlong_t)val);
		} else {
			zfs_nicebytes(val, propbuf, proplen);
		}
		zcp_check(zhp, prop, val, null);
		break;

	default:
		switch (zfs_prop_get_type(prop)) {
		case PROP_TYPE_NUMBER:
			if (get_numeric_property(zhp, prop, src,
			    &source, &val) != 0) {
				return (-1);
			}

			if (literal) {
				(void) snprintf(propbuf, proplen, "%llu",
				    (u_longlong_t)val);
			} else {
				zfs_nicenum(val, propbuf, proplen);
			}
			zcp_check(zhp, prop, val, null);
			break;

		case PROP_TYPE_STRING:
			str = getprop_string(zhp, prop, &source);
			if (str is null)
				return (-1);

			(void) strlcpy(propbuf, str, proplen);
			zcp_check(zhp, prop, 0, str);
			break;

		case PROP_TYPE_INDEX:
			if (get_numeric_property(zhp, prop, src,
			    &source, &val) != 0)
				return (-1);
			if (zfs_prop_index_to_string(prop, val, &strval) != 0)
				return (-1);

			(void) strlcpy(propbuf, strval, proplen);
			zcp_check(zhp, prop, 0, strval);
			break;

		default:
			abort();
		}
	}

	get_source(zhp, src, source, statbuf, statlen);

	return (0);
}

ifdef HAVE_IDMAP
static int
idmap_id_to_numeric_domain_rid(uid_t id, boolean_t isuser,
    char **domainp, idmap_rid_t *ridp)
{
	idmap_get_handle_t *get_hdl = null;
	idmap_stat status;
	int err = EINVAL;

	if (idmap_get_create(&get_hdl) != IDMAP_SUCCESS)
		goto out;

	if (isuser) {
		err = idmap_get_sidbyuid(get_hdl, id,
		    IDMAP_REQ_FLG_USE_CACHE, domainp, ridp, &status);
	} else {
		err = idmap_get_sidbygid(get_hdl, id,
		    IDMAP_REQ_FLG_USE_CACHE, domainp, ridp, &status);
	}
	if (err == IDMAP_SUCCESS &&
	    idmap_get_mappings(get_hdl) == IDMAP_SUCCESS &&
	    status == IDMAP_SUCCESS)
		err = 0;
	else
		err = EINVAL;
out:
	if (get_hdl)
		idmap_get_destroy(get_hdl);
	return (err);
}
#endif /* HAVE_IDMAP */

/*
 * convert the propname into parameters needed by kernel
 * Eg: userquota@ahrens . ZFS_PROP_USERQUOTA, "", 126829
 * Eg: userused@matt@domain . ZFS_PROP_USERUSED, "S-1-123-456", 789
 * Eg: groupquota@staff . ZFS_PROP_GROUPQUOTA, "", 1234
 * Eg: groupused@staff . ZFS_PROP_GROUPUSED, "", 1234
 * Eg: projectquota@123 . ZFS_PROP_PROJECTQUOTA, "", 123
 * Eg: projectused@789 . ZFS_PROP_PROJECTUSED, "", 789
 */
int userQuotaPropertyNameDcode(string propertyName, bool zoned, zfs_userquota_prop_t *typep, char *domain, int domainlen, ulong *ridp)
{
	zfs_userquota_prop_t type;
	char *cp;
	boolean_t isuser;
	boolean_t isgroup;
	boolean_t isproject;
	struct passwd *pw;
	struct group *gr;

	domain[0] = '\0';

	/* Figure out the property type ({user|group|project}{quota|space}) */
	for (type = 0; type < ZFS_NUM_USERQUOTA_PROPS; type++) {
		if (strncmp(propname, zfs_userquota_prop_prefixes[type],
		    strlen(zfs_userquota_prop_prefixes[type])) == 0)
			break;
	}
	if (type == ZFS_NUM_USERQUOTA_PROPS)
		return (EINVAL);
	*typep = type;

	isuser = (type == ZFS_PROP_USERQUOTA || type == ZFS_PROP_USERUSED ||
	    type == ZFS_PROP_USEROBJQUOTA ||
	    type == ZFS_PROP_USEROBJUSED);
	isgroup = (type == ZFS_PROP_GROUPQUOTA || type == ZFS_PROP_GROUPUSED ||
	    type == ZFS_PROP_GROUPOBJQUOTA ||
	    type == ZFS_PROP_GROUPOBJUSED);
	isproject = (type == ZFS_PROP_PROJECTQUOTA ||
	    type == ZFS_PROP_PROJECTUSED || type == ZFS_PROP_PROJECTOBJQUOTA ||
	    type == ZFS_PROP_PROJECTOBJUSED);

	cp = strchr(propname, '@') + 1;

	if (isuser && (pw = getpwnam(cp)) !is null) {
		if (zoned && getzoneid() == GLOBAL_ZONEID)
			return (ENOENT);
		*ridp = pw.pw_uid;
	} else if (isgroup && (gr = getgrnam(cp)) !is null) {
		if (zoned && getzoneid() == GLOBAL_ZONEID)
			return (ENOENT);
		*ridp = gr.gr_gid;
	} else if (!isproject && strchr(cp, '@')) {
#ifdef HAVE_IDMAP
		/*
		 * It's a SID name (eg "user@domain") that needs to be
		 * turned into S-1-domainID-RID.
		 */
		directory_error_t e;
		char *numericsid = null;
		char *end;

		if (zoned && getzoneid() == GLOBAL_ZONEID)
			return (ENOENT);
		if (isuser) {
			e = directory_sid_from_user_name(null,
			    cp, &numericsid);
		} else {
			e = directory_sid_from_group_name(null,
			    cp, &numericsid);
		}
		if (e !is null) {
			directory_error_free(e);
			return (ENOENT);
		}
		if (numericsid is null)
			return (ENOENT);
		cp = numericsid;
		(void) strlcpy(domain, cp, domainlen);
		cp = strrchr(domain, '-');
		*cp = '\0';
		cp++;

		errno = 0;
		*ridp = strtoull(cp, &end, 10);
		free(numericsid);

		if (errno != 0 || *end != '\0')
			return (EINVAL);
#else
		return (ENOSYS);
#endif /* HAVE_IDMAP */
	} else {
		/* It's a user/group/project ID (eg "12345"). */
		uid_t id;
		char *end;
		id = strtoul(cp, &end, 10);
		if (*end != '\0')
			return (EINVAL);
		if (id > MAXUID && !isproject) {
#ifdef HAVE_IDMAP
			/* It's an ephemeral ID. */
			idmap_rid_t rid;
			char *mapdomain;

			if (idmap_id_to_numeric_domain_rid(id, isuser,
			    &mapdomain, &rid) != 0)
				return (ENOENT);
			(void) strlcpy(domain, mapdomain, domainlen);
			*ridp = rid;
#else
			return (ENOSYS);
#endif /* HAVE_IDMAP */
		} else {
			*ridp = id;
		}
	}

	return (0);
}

auto propertyGetUserQuotaCommon(zfs_handle_t *zhp, string propertyName, ulong *propvalue, zfs_userquota_prop_t *typep)
{
	int err;
	zfs_cmd_t zc = {"\0"};

	(void) strlcpy(zc.zc_name, zhp.zfs_name, sizeof (zc.zc_name));

	err = userquota_propname_decode(propname, zfs_prop_get_int(zhp, ZFS_PROP_ZONED), typep, zc.zc_value, sizeof (zc.zc_value), &zc.zc_guid);
	zc.zc_objset_type = *typep;
	enforce(err ==0, "error getting quota");

	err = ioctl(zhp.zfs_hdl.libzfs_fd, ZFS_IOC_USERSPACE_ONE, &zc);
	enforce(err ==0, "error getting quota");
	ulong propertyValue = zc.zc_cookie;
	return propertyValue;
}

int propertyGetUserQuotaInt(zfs_handle_t *zhp, const char *propname, ulong *propvalue)
{
	zfs_userquota_prop_t type;

	return (zfs_prop_get_userquota_common(zhp, propname, propvalue,
	    &type));
}

int zfs_prop_get_userquota(zfs_handle_t *zhp, string propertyName, char *propbuf, int proplen, boolean_t literal)
{
	ulong propertyValue;
	zfs_userquota_prop_t type;

	int err = zfs_prop_get_userquota_common(zhp, propname, &propvalue, &type);
	enforce(err ==0, format!"failed to get userQuota for %s"(propertyName));

	if (literal)
		return "%s"(propertyValue);

	switch(type) with (ZfsUserQuotaPropertyType)
	{
		case userQuota, groupQuota, userObjQuota, groupObjQuota, projectQuota, projectObjQuota:
			return (propertyValue == 0) ? "none" : niceQformat!"%s"(propertyValue);

		case userQuota
	} else if (type == ZFS_PROP_USERQUOTA || type == ZFS_PROP_GROUPQUOTA ||
	    type == ZFS_PROP_USERUSED || type == ZFS_PROP_GROUPUSED ||
	    type == ZFS_PROP_PROJECTUSED || type == ZFS_PROP_PROJECTQUOTA) {
		zfs_nicebytes(propvalue, propbuf, proplen);
	} else {
		zfs_nicenum(propvalue, propbuf, proplen);
	}
}

bool typeHasNone(ZfsUserQuotaPropertyType type)
{
	switch(type) with (ZfsUserQuotaPropertyType)
	{
		case userQuota, groupQuota, userObjQuota, groupObjQuota, projectQuota, projectObjQuota:
			return "none";
		(type == ZFS_PROP_USERQUOTA || type == ZFS_PROP_GROUPQUOTA ||
	    type == ZFS_PROP_USEROBJQUOTA || type == ZFS_PROP_GROUPOBJQUOTA ||
	    type == ZFS_PROP_PROJECTQUOTA ||
	    type == ZFS_PROP_PROJECTOBJQUOTA)) {
		(void) strlcpy(propbuf, "none", proplen);
	} else if (type == ZFS_PROP_USERQUOTA || type == ZFS_PROP_GROUPQUOTA ||

int
zfs_prop_get_written_int(zfs_handle_t *zhp, const char *propname,
    ulong *propvalue)
{
	int err;
	zfs_cmd_t zc = {"\0"};
	const char *snapname;

	(void) strlcpy(zc.zc_name, zhp.zfs_name, sizeof (zc.zc_name));

	snapname = strchr(propname, '@') + 1;
	if (strchr(snapname, '@')) {
		(void) strlcpy(zc.zc_value, snapname, sizeof (zc.zc_value));
	} else {
		/* snapname is the short name, append it to zhp's fsname */
		char *cp;

		(void) strlcpy(zc.zc_value, zhp.zfs_name,
		    sizeof (zc.zc_value));
		cp = strchr(zc.zc_value, '@');
		if (cp !is null)
			*cp = '\0';
		(void) strlcat(zc.zc_value, "@", sizeof (zc.zc_value));
		(void) strlcat(zc.zc_value, snapname, sizeof (zc.zc_value));
	}

	err = ioctl(zhp.zfs_hdl.libzfs_fd, ZFS_IOC_SPACE_WRITTEN, &zc);
	if (err)
		return (err);

	*propvalue = zc.zc_cookie;
	return (0);
}

string propertyGetWritten(zfs_handle_t *zhp, string propertyName, bool literal)
{
	int err;
	ulong propertyValue;
	enforce((err=zfs_prop_get_written_int(zhp, propertyName.toCString, &propertyValue)) ==0, format!"error %s"(err));
	return (literal) ? format!"%llu"(propertyValue) : niceBytes(propertyValue);
}

@SILdoc(`Returns the name of the given zfs handle.`)
string getName(const zfs_handle_t *zhp)
{
	return (zhp.zfs_name).fromCString.idup;
}

@SILdoc(`Returns the name of the parent pool for the given zfs handle.`)
string getPoolName(const zfs_handle_t *zhp)
{
	return (zhp.zpool_hdl.zpool_name).fromCString.idup;
}

@SILdoc(`Returns the type of the given zfs handle`)
zfs_type_t zfs_get_type(const zfs_handle_t *zhp)
{
	return (zhp.zfs_type);
}

/*
 * Is one dataset name a child dataset of another?
 *
 * Needs to handle these cases:
 * Dataset 1	"a/foo"		"a/foo"		"a/foo"		"a/foo"
 * Dataset 2	"a/fo"		"a/foobar"	"a/bar/baz"	"a/foo/bar"
 * Descendant?	No.		No.		No.		Yes.
 */
bool isDescendant(string dataset1, string dataset2)
{
	size_t d1len = strlen(ds1);

	/* ds2 can't be a descendant if it's smaller */
	if (strlen(ds2) < d1len)
		return (B_FALSE);

	/* otherwise, compare strings and verify that there's a '/' char */
	return (ds2[d1len] == '/' && (strncmp(ds1, ds2, d1len) == 0));
}

// Given a complete name, return just the portion that refers to the parent. Will return -1 if there is no parent (path is just the name of the pool).
string parentName(string path)
{
	char[ZFS_MAX_DATASET_NAME_LEN] buf;
	char *slashp;

	(void) strlcpy(buf, path, buflen);

	if ((slashp = strrchr(buf, '/')) is null)
		return (-1);
	*slashp = '\0';
	return (0);
}

string parentName(zfs_handle_t *zhp)
{
	char[ZFS_MAX_DATASET_NAME_LEN] buf;
	enforce(parent_name(zfs_get_name(zhp), buf.ptr, buf.length)==0);
	return buf.idup;
}

/*
 * If accept_ancestor is false, then check to make sure that the given path has
 * a parent, and that it exists.  If accept_ancestor is true, then find the
 * closest existing ancestor for the given path.  In prefixlen return the
 * length of already existing prefix of the given path.  We also fetch the
 * 'zoned' property, which is used to validate property settings when creating
 * new datasets.
 */
auto checkParents(string path, bool acceptAncestor)
{
	libzfs_handle_t* hdl = libZfsHandle;

	ulong zoned; // return 1

	zfs_cmd_t zc = {"\0"};
	char parent[ZFS_MAX_DATASET_NAME_LEN];
	char *slash;
	zfs_handle_t *zhp;
	ulong isZoned;

	auto errbuf= format!"cannot create %s"(path);

	// get parent, and check to see if this is just a pool
	enfoce(parent_name(path, parent, sizeof (parent)) ==0,
				new ZfsException(EZFS_INVALIDNAME,format!"cannot create %s: missing dataset name"(path)));

	// check to see if the pool exists
	if ((slash = strchr(parent, '/')) is null)
		slash = parent + strlen(parent);
	(void) strncpy(zc.zc_name, parent, slash - parent);
	zc.zc_name[slash - parent] = '\0';
	if (ioctl(hdl.libzfs_fd, ZFS_IOC_OBJSET_STATS, &zc) != 0 && errno == ENOENT) {
		zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "no such pool '%s'"), zc.zc_name);
		return (zfs_error(hdl, EZFS_NOENT, errbuf));
	}

	/* check to see if the parent dataset exists */
	while ((zhp = make_dataset_handle(hdl, parent)) is null)
	{
		if (errno == ENOENT && acceptAncestor) {
			 // Go deeper to find an ancestor, give up on top level.
			if (parent_name(parent, parent, sizeof (parent)) != 0)
			{
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "no such pool '%s'"), zc.zc_name);
				return (zfs_error(hdl, EZFS_NOENT, errbuf));
			}
		} else if (errno == ENOENT) {
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "parent does not exist"));
			return (zfs_error(hdl, EZFS_NOENT, errbuf));
		} else
			return (zfs_standard_error(hdl, errno, errbuf));
	}

	isZoned = zfs_prop_get_int(zhp, ZFS_PROP_ZONED);
	if (zoned !is null)
		zoned = isZoned;

	// we are in a non-global zone, but parent is in the global zone
	if (getzoneid() != GLOBAL_ZONEID && !isZoned) {
		(void) zfs_standard_error(hdl, EPERM, errbuf);
		zfs_close(zhp);
		return (-1);
	}

	// make sure parent is a filesystem
	if (zfs_get_type(zhp) != ZFS_TYPE_FILESYSTEM) {
		zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "parent is not a filesystem"));
		(void) zfs_error(hdl, EZFS_BADTYPE, errbuf);
		zfs_close(zhp);
		return (-1);
	}

	zfs_close(zhp);
	return tuple(zoned,strlen(parent));
}

@SILdoc(`Given a path to 'target', create all the ancestors between the prefixlen portion of the path, and the target itself.  Fail if the initial prefixlen-ancestor does not already exist.`)
void createParents(string target, int prefixLen)
{
	import std.format:format;
	libzfs_handle_t* hdl = libZfsHandle;
	zfs_handle_t *h;
	char *cp;
	const char *opname;

	// make sure prefix exists
	cp = target + prefixlen;
	if (*cp != '/')
	{
		enforce(!cp.canFind("/"));
		h = open(target, ZfsType.filesystem);
	} else
	{
		cp = '\0';
		h = zfs_open(hdl, target, ZfsType.filesystem);
		cp = '/';
	}
	enforce(h !is null, "createParents failed");
	zfs_close(h);

	// Attempt to create, mount, and share any ancestor filesystems, up to the prefixlen-long one.
	for (cp = target + prefixlen + 1; (cp = strchr(cp, '/')) !is null; *cp = '/', cp++)
	{
		*cp = '\0';
		h = makeDatasetHandle(target);
		if (h) {
			/* it already exists, nothing to do here */
			zfs_close(h);
			continue;
		}

		enum Failed = "failed to %s ancestor %s";
		enforce(create(target, ZfsType.filesystem,null) ==0, format!Failed("create",target));
		enforce( (h = open(target, ZfsType.filesystem)) == 0, format!Failed("open",target));
		enforce( mount(target, ZfsType.filesystem))  == 0 , format!Failed("mount",target));
		enforce( share(h)  == 0 , format!Failed("share",target));
		zfs_close(h);
	}
}

@SILdoc(`Creates non-existing ancestors of the given path.`)
void createAncestors(string path)
{
	import std.format:format;
	libzfs_handle_t* hdl = libZfsHandle;
	int prefix;
	char *path_copy;
	char errbuf[1024];
	int rc = 0;

	(void) snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN,
	    "cannot create '%s'"), path);

	// Check that we are not passing the nesting limit before we start creating any ancestors.
	enforce(dataset_nestcheck(path) ==0, new ZfsException(EZFS_INVALIDNAME,format!"maximum name nesting depth exceeded: cannot create %s"(path)));

	if (check_parents(hdl, path, null, B_TRUE, &prefix) != 0)
		return (-1);
	createParents(path,prefix);
}

enum ZfsMountShareResult
{
	success,
	cannotOpen,
	cannotDoForVolume,
	successfullyCreatedButOnlyRootCanMount,
	successfullyCreatedButNotMounted,
	successfullyCreatedButNotShared,
}




@SILdoc(`Retrieve a property from the given object.  If 'literal' is specified, then numbers are left as exact values.  Otherwise, numbers are converted to a human-readable form.`)
string propertyGet(zfs_handle_t *zhp, zfs_prop_t prop, zprop_source_t *src, char *statbuf, size_t statlen, bool literalNotFriendly)
{
	import std.format:format;
	char[4096] propBuf;
	auto result = zfs_prop_get(zhp, prop, propBuf.ptr, probBuf.sizeof, src, statbuf, statlen, literalNotFriendly ? 1 : 0);
	enforce(result == 0, format!"error %s retrieving property from zfs object");
	return propBuf.idup;
}

@SILdoc(`Utility function to get the given numeric property.  Does no validation that the given property is the appropriate type; should only be used with hard-coded property types.`)
ulong propertyGetT(T)(zfs_handle_t *zhp, zfs_prop_t prop)
if (is(T==ulong))
{
	char *source;
	ulong val = 0;
	get_numeric_property(zhp, prop, null, &source, &val);
	return val;
}

}

@SILdoc(`Create a new filesystem or volume.`)
void create(string path, ZfsType type, Variable[string] props)
{
	libzfs_handle_t* hdl = libZfsHandle;
	int ret;
	ulong size = 0;
	ulong blocksize = zfs_prop_default_numeric(ZFS_PROP_VOLBLOCKSIZE);
	ulong zoned;
	enum lzc_dataset_type ost;
	zpool_handle_t *zpool_handle;
	uint8_t *wkeydata = null;
	uint_t wkeylen = 0;
	char errbuf[1024];
	char parent[ZFS_MAX_DATASET_NAME_LEN];

	(void) snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN,
	    "cannot create '%s'"), path);

	/* validate the path, taking care to note the extended error message */
	if (!zfs_validate_name(hdl, path, type, B_TRUE))
		return (zfs_error(hdl, EZFS_INVALIDNAME, errbuf));

	if (dataset_nestcheck(path) != 0) {
		zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
		    "maximum name nesting depth exceeded"));
		return (zfs_error(hdl, EZFS_INVALIDNAME, errbuf));
	}

	/* validate parents exist */
	if (check_parents(hdl, path, &zoned, B_FALSE, null) != 0)
		return (-1);

	/*
	 * The failure modes when creating a dataset of a different type over
	 * one that already exists is a little strange.  In particular, if you
	 * try to create a dataset on top of an existing dataset, the ioctl()
	 * will return ENOENT, not EEXIST.  To prevent this from happening, we
	 * first try to see if the dataset exists.
	 */
	if (zfs_dataset_exists(hdl, path, ZFS_TYPE_DATASET)) {
		zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
		    "dataset already exists"));
		return (zfs_error(hdl, EZFS_EXISTS, errbuf));
	}

	if (type == ZFS_TYPE_VOLUME)
		ost = LZC_DATSET_TYPE_ZVOL;
	else
		ost = LZC_DATSET_TYPE_ZFS;

	/* open zpool handle for prop validation */
	char pool_path[ZFS_MAX_DATASET_NAME_LEN];
	(void) strlcpy(pool_path, path, sizeof (pool_path));

	/* truncate pool_path at first slash */
	char *p = strchr(pool_path, '/');
	if (p !is null)
		*p = '\0';

	if ((zpool_handle = zpool_open(hdl, pool_path)) is null)
		return (-1);

	if (props && (props = zfs_valid_proplist(hdl, type, props,
	    zoned, null, zpool_handle, B_TRUE, errbuf)) == 0) {
		zpool_close(zpool_handle);
		return (-1);
	}
	zpool_close(zpool_handle);

	if (type == ZFS_TYPE_VOLUME) {
		/*
		 * If we are creating a volume, the size and block size must
		 * satisfy a few restraints.  First, the blocksize must be a
		 * valid block size between SPA_{MIN,MAX}BLOCKSIZE.  Second, the
		 * volsize must be a multiple of the block size, and cannot be
		 * zero.
		 */
		if (props is null || nvlist_lookup_uint64(props,
		    zfs_prop_to_name(ZFS_PROP_VOLSIZE), &size) != 0) {
			nvlist_free(props);
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "missing volume size"));
			return (zfs_error(hdl, EZFS_BADPROP, errbuf));
		}

		if ((ret = nvlist_lookup_uint64(props,
		    zfs_prop_to_name(ZFS_PROP_VOLBLOCKSIZE),
		    &blocksize)) != 0) {
			if (ret == ENOENT) {
				blocksize = zfs_prop_default_numeric(
				    ZFS_PROP_VOLBLOCKSIZE);
			} else {
				nvlist_free(props);
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
				    "missing volume block size"));
				return (zfs_error(hdl, EZFS_BADPROP, errbuf));
			}
		}

		if (size == 0) {
			nvlist_free(props);
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "volume size cannot be zero"));
			return (zfs_error(hdl, EZFS_BADPROP, errbuf));
		}

		if (size % blocksize != 0) {
			nvlist_free(props);
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "volume size must be a multiple of volume block "
			    "size"));
			return (zfs_error(hdl, EZFS_BADPROP, errbuf));
		}
	}

	(void) parent_name(path, parent, sizeof (parent));
	if (zfs_crypto_create(hdl, parent, props, null, B_TRUE,
	    &wkeydata, &wkeylen) != 0) {
		nvlist_free(props);
		return (zfs_error(hdl, EZFS_CRYPTOFAILED, errbuf));
	}

	/* create the dataset */
	ret = lzc_create(path, ost, props, wkeydata, wkeylen);
	nvlist_free(props);
	if (wkeydata !is null)
		free(wkeydata);

	/* check for failure */
	if (ret != 0) {
		switch (errno) {
		case ENOENT:
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "no such parent '%s'"), parent);
			return (zfs_error(hdl, EZFS_NOENT, errbuf));

		case ENOTSUP:
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "pool must be upgraded to set this "
			    "property or value"));
			return (zfs_error(hdl, EZFS_BADVERSION, errbuf));

		case EACCES:
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "encryption root's key is not loaded "
			    "or provided"));
			return (zfs_error(hdl, EZFS_CRYPTOFAILED, errbuf));

		case ERANGE:
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "invalid property value(s) specified"));
			return (zfs_error(hdl, EZFS_BADPROP, errbuf));
#ifdef _ILP32
		case EOVERFLOW:
			/*
			 * This platform can't address a volume this big.
			 */
			if (type == ZFS_TYPE_VOLUME)
				return (zfs_error(hdl, EZFS_VOLTOOBIG,
				    errbuf));
#endif
			/* FALLTHROUGH */
		default:
			return (zfs_standard_error(hdl, errno, errbuf));
		}
	}

	return (0);
}

/*
 * Destroys the given dataset.  The caller must make sure that the filesystem
 * isn't mounted, and that there are no active dependents. If the file system
 * does not exist this function does nothing.
 */
void destroy(zfs_handle_t *zhp, bool defer)
{
	int error;

	if (zhp.zfs_type != ZFS_TYPE_SNAPSHOT && defer)
		return (EINVAL);

	if (zhp.zfs_type == ZFS_TYPE_BOOKMARK) {
		nvlist_t *nv = fnvlist_alloc();
		fnvlist_add_boolean(nv, zhp.zfs_name);
		error = lzc_destroy_bookmarks(nv, null);
		fnvlist_free(nv);
		if (error != 0) {
			return (zfs_standard_error_fmt(zhp.zfs_hdl, error,
			    dgettext(TEXT_DOMAIN, "cannot destroy '%s'"),
			    zhp.zfs_name));
		}
		return (0);
	}

	if (zhp.zfs_type == ZFS_TYPE_SNAPSHOT) {
		nvlist_t *nv = fnvlist_alloc();
		fnvlist_add_boolean(nv, zhp.zfs_name);
		error = lzc_destroy_snaps(nv, defer, null);
		fnvlist_free(nv);
	} else {
		error = lzc_destroy(zhp.zfs_name);
	}

	if (error != 0 && error != ENOENT) {
		return (zfs_standard_error_fmt(zhp.zfs_hdl, errno,
		    dgettext(TEXT_DOMAIN, "cannot destroy '%s'"),
		    zhp.zfs_name));
	}

	remove_mountpoint(zhp);

	return (0);
}

struct destroydata
{
	nvlist_t *nvl;
	string name;
};

static int checkSnapCallback(zfs_handle_t *zhp, void *arg)
{
	struct destroydata *dd = arg;
	char name[ZFS_MAX_DATASET_NAME_LEN];
	int rv = 0;

	if (snprintf(name, sizeof (name), "%s@%s", zhp.zfs_name,
	    dd.snapname) >= sizeof (name))
		return (EINVAL);

	if (lzc_exists(name))
		verify(nvlist_add_boolean(dd.nvl, name) == 0);

	rv = zfs_iter_filesystems(zhp, zfs_check_snap_cb, dd);
	zfs_close(zhp);
	return (rv);
}


@SILdoc(`Destroys all snapshots with the given name in zhp & descendants.`)
void destroySnapshot(zfs_handle_t *zhp, string snapshotName, bool defer)
{
	int ret;
	destroydata dd = { 0 };

	dd.snapname = snapname;
	verify(nvlist_alloc(&dd.nvl, NV_UNIQUE_NAME, 0) == 0);
	(void) zfs_check_snap_cb(zfs_handle_dup(zhp), &dd);

	if (nvlist_empty(dd.nvl)) {
		ret = zfs_standard_error_fmt(zhp.zfs_hdl, ENOENT,
		    dgettext(TEXT_DOMAIN, "cannot destroy '%s@%s'"),
		    zhp.zfs_name, snapname);
	} else {
		ret = zfs_destroy_snaps_nvl(zhp.zfs_hdl, dd.nvl, defer);
	}
	nvlist_free(dd.nvl);
	return (ret);
}

// Destroys all the snapshots named in the nvlist.
void destroySnapshots(libzfs_handle_t *hdl, string[] snaps, boolean_t defer)
{
	int ret;
	nvlist_t *errlist = null;
	nvpair_t *pair;

	ret = lzc_destroy_snaps(snaps, defer, &errlist);

	if (ret == 0) {
		nvlist_free(errlist);
		return (0);
	}

	if (nvlist_empty(errlist)) {
		char errbuf[1024];
		(void) snprintf(errbuf, sizeof (errbuf),
		    dgettext(TEXT_DOMAIN, "cannot destroy snapshots"));

		ret = zfs_standard_error(hdl, ret, errbuf);
	}
	for (pair = nvlist_next_nvpair(errlist, null);
	    pair !is null; pair = nvlist_next_nvpair(errlist, pair)) {
		char errbuf[1024];
		(void) snprintf(errbuf, sizeof (errbuf),
		    dgettext(TEXT_DOMAIN, "cannot destroy snapshot %s"),
		    nvpair_name(pair));

		switch (fnvpair_value_int32(pair)) {
		case EEXIST:
			zfs_error_aux(hdl,
			    dgettext(TEXT_DOMAIN, "snapshot is cloned"));
			ret = zfs_error(hdl, EZFS_EXISTS, errbuf);
			break;
		default:
			ret = zfs_standard_error(hdl, errno, errbuf);
			break;
		}
	}

	nvlist_free(errlist);
	return (ret);
}

// Clones the given dataset.  The target must be of the same type as the source.
void clone(zfs_handle_t *zhp, string target, nvlist_t *props)
{
	char parent[ZFS_MAX_DATASET_NAME_LEN];
	int ret;
	char errbuf[1024];
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	ulong zoned;

	assert(zhp.zfs_type == ZFS_TYPE_SNAPSHOT);

	(void) snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN,
	    "cannot create '%s'"), target);

	// validate the target/clone name
	if (!zfs_validate_name(hdl, target, ZFS_TYPE_FILESYSTEM, B_TRUE))
		return (zfs_error(hdl, EZFS_INVALIDNAME, errbuf));

	// validate parents exist
	if (check_parents(hdl, target, &zoned, B_FALSE, null) != 0)
		return (-1);

	parent_name(target, parent, sizeof (parent));

	// do the clone

	if (props) {
		zfs_type_t type;

		if (ZFS_IS_VOLUME(zhp)) {
			type = ZFS_TYPE_VOLUME;
		} else {
			type = ZFS_TYPE_FILESYSTEM;
		}
		if ((props = zfs_valid_proplist(hdl, type, props, zoned,
		    zhp, zhp.zpool_hdl, B_TRUE, errbuf)) is null)
			return (-1);
		if (zfs_fix_auto_resv(zhp, props) == -1) {
			nvlist_free(props);
			return (-1);
		}
	}

	if (zfs_crypto_clone_check(hdl, zhp, parent, props) != 0) {
		nvlist_free(props);
		return (zfs_error(hdl, EZFS_CRYPTOFAILED, errbuf));
	}

	ret = lzc_clone(target, zhp.zfs_name, props);
	nvlist_free(props);

	if (ret != 0) {
		switch (errno) {

		case ENOENT:
			/*
			 * The parent doesn't exist.  We should have caught this
			 * above, but there may a race condition that has since
			 * destroyed the parent.
			 *
			 * At this point, we don't know whether it's the source
			 * that doesn't exist anymore, or whether the target
			 * dataset doesn't exist.
			 */
			zfs_error_aux(zhp.zfs_hdl, dgettext(TEXT_DOMAIN,
			    "no such parent '%s'"), parent);
			return (zfs_error(zhp.zfs_hdl, EZFS_NOENT, errbuf));

		case EXDEV:
			zfs_error_aux(zhp.zfs_hdl, dgettext(TEXT_DOMAIN,
			    "source and target pools differ"));
			return (zfs_error(zhp.zfs_hdl, EZFS_CROSSTARGET,
			    errbuf));

		default:
			return (zfs_standard_error(zhp.zfs_hdl, errno,
			    errbuf));
		}
	}

	return (ret);
}

@SILdoc(`Promotes the given clone fs to be the clone parent.`)
void promote(zfs_handle_t *zhp)
{
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	char snapname[ZFS_MAX_DATASET_NAME_LEN];
	int ret;
	char errbuf[1024];

	(void) snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN,
	    "cannot promote '%s'"), zhp.zfs_name);

	if (zhp.zfs_type == ZFS_TYPE_SNAPSHOT) {
		zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
		    "snapshots can not be promoted"));
		return (zfs_error(hdl, EZFS_BADTYPE, errbuf));
	}

	if (zhp.zfs_dmustats.dds_origin[0] == '\0') {
		zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
		    "not a cloned filesystem"));
		return (zfs_error(hdl, EZFS_BADTYPE, errbuf));
	}

	if (!zfs_validate_name(hdl, zhp.zfs_name, zhp.zfs_type, B_TRUE))
		return (zfs_error(hdl, EZFS_INVALIDNAME, errbuf));

	ret = lzc_promote(zhp.zfs_name, snapname, sizeof (snapname));

	if (ret != 0) {
		switch (ret) {
		case EEXIST:
			/* There is a conflicting snapshot name. */
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "conflicting snapshot '%s' from parent '%s'"),
			    snapname, zhp.zfs_dmustats.dds_origin);
			return (zfs_error(hdl, EZFS_EXISTS, errbuf));

		default:
			return (zfs_standard_error(hdl, ret, errbuf));
		}
	}
	return (ret);
}

struct Snapdata
{
	nvlist_t *sd_nvl;
	string name;
}

void snapshotCallback(zfs_handle_t *zhp, Snapdata* sd)
{
	snapdata_t *sd = arg;
	char name[ZFS_MAX_DATASET_NAME_LEN];
	int rv = 0;

	if (zfs_prop_get_int(zhp, ZFS_PROP_INCONSISTENT) == 0) {
		if (snprintf(name, sizeof (name), "%s@%s", zfs_get_name(zhp),
		    sd.sd_snapname) >= sizeof (name))
			return (EINVAL);

		fnvlist_add_boolean(sd.sd_nvl, name);

		rv = zfs_iter_filesystems(zhp, zfs_snapshot_cb, sd);
	}
	zfs_close(zhp);

	return (rv);
}

void remapIndirects(string fs)
{
	int err;
	char errbuf[1024];

	(void) snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN, "cannot remap dataset '%s'"), fs);

	err = lzc_remap(fs);

	if (err != 0) {
		switch (err) {
		case ENOTSUP:
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "pool must be upgraded"));
			(void) zfs_error(hdl, EZFS_BADVERSION, errbuf);
			break;
		case EINVAL:
			(void) zfs_error(hdl, EZFS_BADTYPE, errbuf);
			break;
		default:
			(void) zfs_standard_error(hdl, err, errbuf);
			break;
		}
	}

	return (err);
}

// Creates snapshots.  The keys in the snaps nvlist are the snapshots to be created.
void snapshot(string[] snapshotNames, Variable[string] properties)
{
	// nvlist_t *snaps, nvlist_t *props)
	libzfs_handle_t *hdl = libZfsHandle;
	int ret;
	char errbuf[1024];
	nvpair_t *elem;
	nvlist_t *errors;
	zpool_handle_t *zpool_hdl;
	char pool[ZFS_MAX_DATASET_NAME_LEN];

	(void) snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN, "cannot create snapshots "));

	elem = null;
	while ((elem = nvlist_next_nvpair(snaps, elem)) !is null)
	{
		const char *snapname = nvpair_name(elem);

		/* validate the target name */
		if (!zfs_validate_name(hdl, snapname, ZFS_TYPE_SNAPSHOT,
		    B_TRUE)) {
			(void) snprintf(errbuf, sizeof (errbuf),
			    dgettext(TEXT_DOMAIN,
			    "cannot create snapshot '%s'"), snapname);
			return (zfs_error(hdl, EZFS_INVALIDNAME, errbuf));
		}
	}

	/*
	 * get pool handle for prop validation. assumes all snaps are in the
	 * same pool, as does lzc_snapshot (below).
	 */
	elem = nvlist_next_nvpair(snaps, null);
	(void) strlcpy(pool, nvpair_name(elem), sizeof (pool));
	pool[strcspn(pool, "/@")] = '\0';
	zpool_hdl = zpool_open(hdl, pool);
	if (zpool_hdl is null)
		return (-1);

	if (props !is null &&
	    (props = zfs_valid_proplist(hdl, ZFS_TYPE_SNAPSHOT,
	    props, B_FALSE, null, zpool_hdl, B_FALSE, errbuf)) is null) {
		zpool_close(zpool_hdl);
		return (-1);
	}
	zpool_close(zpool_hdl);

	ret = lzc_snapshot(snaps, props, &errors);

	if (ret != 0) {
		boolean_t printed = B_FALSE;
		for (elem = nvlist_next_nvpair(errors, null);
		    elem !is null;
		    elem = nvlist_next_nvpair(errors, elem)) {
			(void) snprintf(errbuf, sizeof (errbuf),
			    dgettext(TEXT_DOMAIN,
			    "cannot create snapshot '%s'"), nvpair_name(elem));
			(void) zfs_standard_error(hdl,
			    fnvpair_value_int32(elem), errbuf);
			printed = B_TRUE;
		}
		if (!printed) {
			switch (ret) {
			case EXDEV:
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
				    "multiple snapshots of same "
				    "fs not allowed"));
				(void) zfs_error(hdl, EZFS_EXISTS, errbuf);

				break;
			default:
				(void) zfs_standard_error(hdl, ret, errbuf);
			}
		}
	}

	nvlist_free(props);
	nvlist_free(errors);
	return (ret);
}

void snapshot(string path, bool recursive, Variable[string] properties)
{
	libzfs_handle_t* hdl = libZfsHandle;
	int ret;
	snapdata_t sd = { 0 };
	string fsname; // char fsname[ZFS_MAX_DATASET_NAME_LEN];
	char *cp;
	zfs_handle_t *zhp;

	auto errbuf = format!"cannot snapshot %s"(path);

	if (!zfs_validate_name(hdl, path, ZFS_TYPE_SNAPSHOT, B_TRUE))
		return (zfs_error(hdl, EZFS_INVALIDNAME, errbuf));

	(void) strlcpy(fsname, path, sizeof (fsname));
	cp = strchr(fsname, '@');
	*cp = '\0';
	sd.sd_snapname = cp + 1;

	if ((zhp = zfs_open(hdl, fsname, ZFS_TYPE_FILESYSTEM |
	    ZFS_TYPE_VOLUME)) is null) {
		return (-1);
	}

	enforce(nvlist_alloc(&sd.sd_nvl, NV_UNIQUE_NAME, 0) == 0);
	if (recursive) {
		zfs_snapshot_cb(zfs_handle_dup(zhp), &sd);
	} else {
		fnvlist_add_boolean(sd.sd_nvl, path);
	}

	ret = zfs_snapshot_nvl(hdl, sd.sd_nvl, props);
	nvlist_free(sd.sd_nvl);
	zfs_close(zhp);
	enforce(ret == 0, new ZfsException(format!"error %s snapshot"(ret));
}

/*
 * Destroy any more recent snapshots.  We invoke this callback on any dependents
 * of the snapshot first.  If the 'cb_dependent' member is non-zero, then this
 * is a dependent and we should just destroy it without checking the transaction
 * group.
 */
struct rollback_data_t
{
	string cb_target;		/* the snapshot */
	ulong	cb_create;		/* creation time reference */
	boolean_t	cb_error;
	boolean_t	cb_force;
} rollback_data_t;

void rollbackDestroyDependent(zfs_handle_t *zhp, rollback_data* cbp)
{
	prop_changelist_t *clp;

	/* We must destroy this clone; first unmount it */
	clp = changelist_gather(zhp, ZFS_PROP_NAME, 0,
	    cbp.cb_force ? MS_FORCE: 0);
	if (clp is null || changelist_prefix(clp) != 0) {
		cbp.cb_error = B_TRUE;
		zfs_close(zhp);
		return (0);
	}
	if (zfs_destroy(zhp, B_FALSE) != 0)
		cbp.cb_error = B_TRUE;
	else
		changelist_remove(clp, zhp.zfs_name);
	(void) changelist_postfix(clp);
	changelist_free(clp);

	zfs_close(zhp);
	return (0);
}

void rollbackDestroy(zfs_handle_t *zhp, void *data)
{
	rollback_data_t *cbp = data;

	if (zfs_prop_get_int(zhp, ZFS_PROP_CREATETXG) > cbp.cb_create) {
		cbp.cb_error |= zfs_iter_dependents(zhp, B_FALSE,
		    rollback_destroy_dependent, cbp);

		cbp.cb_error |= zfs_destroy(zhp, B_FALSE);
	}

	zfs_close(zhp);
	return (0);
}

@SILdoc(`Given a dataset, rollback to a specific snapshot, discarding any data changes since then and making it the active dataset.

Any snapshots and bookmarks more recent than the target are destroyed, along with their dependents (i.e. clones).
`)
void rollback(zfs_handle_t *zhp, zfs_handle_t *snap, bool force)
{
	rollback_data_t cb = { 0 };
	int err;
	boolean_t restore_resv = 0;
	ulong old_volsize = 0, new_volsize;
	zfs_prop_t resv_prop = { 0 };
	ulong min_txg = 0;

	assert(zhp.zfs_type == ZFS_TYPE_FILESYSTEM ||
	    zhp.zfs_type == ZFS_TYPE_VOLUME);

	/*
	 * Destroy all recent snapshots and their dependents.
	 */
	cb.cb_force = force;
	cb.cb_target = snap.zfs_name;
	cb.cb_create = zfs_prop_get_int(snap, ZFS_PROP_CREATETXG);

	if (cb.cb_create > 0)
		min_txg = cb.cb_create;

	(void) zfs_iter_snapshots(zhp, B_FALSE, rollback_destroy, &cb,
	    min_txg, 0);

	(void) zfs_iter_bookmarks(zhp, rollback_destroy, &cb);

	if (cb.cb_error)
		return (-1);

	/*
	 * Now that we have verified that the snapshot is the latest,
	 * rollback to the given snapshot.
	 */

	if (zhp.zfs_type == ZFS_TYPE_VOLUME) {
		if (zfs_which_resv_prop(zhp, &resv_prop) < 0)
			return (-1);
		old_volsize = zfs_prop_get_int(zhp, ZFS_PROP_VOLSIZE);
		restore_resv =
		    (old_volsize == zfs_prop_get_int(zhp, resv_prop));
	}

	/*
	 * Pass both the filesystem and the wanted snapshot names,
	 * we would get an error back if the snapshot is destroyed or
	 * a new snapshot is created before this request is processed.
	 */
	err = lzc_rollback_to(zhp.zfs_name, snap.zfs_name);
	if (err != 0) {
		char errbuf[1024];

		(void) snprintf(errbuf, sizeof (errbuf),
		    dgettext(TEXT_DOMAIN, "cannot rollback '%s'"),
		    zhp.zfs_name);
		switch (err) {
		case EEXIST:
			zfs_error_aux(zhp.zfs_hdl, dgettext(TEXT_DOMAIN,
			    "there is a snapshot or bookmark more recent "
			    "than '%s'"), snap.zfs_name);
			(void) zfs_error(zhp.zfs_hdl, EZFS_EXISTS, errbuf);
			break;
		case ESRCH:
			zfs_error_aux(zhp.zfs_hdl, dgettext(TEXT_DOMAIN,
			    "'%s' is not found among snapshots of '%s'"),
			    snap.zfs_name, zhp.zfs_name);
			(void) zfs_error(zhp.zfs_hdl, EZFS_NOENT, errbuf);
			break;
		case EINVAL:
			(void) zfs_error(zhp.zfs_hdl, EZFS_BADTYPE, errbuf);
			break;
		default:
			(void) zfs_standard_error(zhp.zfs_hdl, err, errbuf);
		}
		return (err);
	}

	/*
	 * For volumes, if the pre-rollback volsize matched the pre-
	 * rollback reservation and the volsize has changed then set
	 * the reservation property to the post-rollback volsize.
	 * Make a new handle since the rollback closed the dataset.
	 */
	if ((zhp.zfs_type == ZFS_TYPE_VOLUME) &&
	    (zhp = make_dataset_handle(zhp.zfs_hdl, zhp.zfs_name))) {
		if (restore_resv) {
			new_volsize = zfs_prop_get_int(zhp, ZFS_PROP_VOLSIZE);
			if (old_volsize != new_volsize)
				err = zfs_prop_set_int(zhp, resv_prop,
				    new_volsize);
		}
		zfs_close(zhp);
	}
	return (err);
}

// Renames the given dataset.
void renameDataset(zfs_handle_t *zhp, const char *target, boolean_t recursive, boolean_t force_unmount)
{
	int ret = 0;
	zfs_cmd_t zc = {"\0"};
	char *delim;
	prop_changelist_t *cl = null;
	char parent[ZFS_MAX_DATASET_NAME_LEN];
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	char errbuf[1024];

	/* if we have the same exact name, just return success */
	if (strcmp(zhp.zfs_name, target) == 0)
		return (0);

	snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN, "cannot rename to '%s'"), target);

	// make sure source name is valid
	if (!zfs_validate_name(hdl, zhp.zfs_name, zhp.zfs_type, B_TRUE))
		return (zfs_error(hdl, EZFS_INVALIDNAME, errbuf));

	// Make sure the target name is valid
	if (zhp.zfs_type == ZFS_TYPE_SNAPSHOT) {
		if ((strchr(target, '@') is null) ||
		    *target == '@') {
			 // Snapshot target name is abbreviated, reconstruct full dataset name
			strlcpy(parent, zhp.zfs_name, sizeof (parent));
			delim = strchr(parent, '@');
			if (strchr(target, '@') is null)
				*(++delim) = '\0';
			else
				*delim = '\0';
			(void) strlcat(parent, target, sizeof (parent));
			target = parent;
		} else {
			 // Make sure we're renaming within the same dataset.
			delim = strchr(target, '@');
			if (strncmp(zhp.zfs_name, target, delim - target)
			    != 0 || zhp.zfs_name[delim - target] != '@') {
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
				    "snapshots must be part of same "
				    "dataset"));
				return (zfs_error(hdl, EZFS_CROSSTARGET,
				    errbuf));
			}
		}

		if (!zfs_validate_name(hdl, target, zhp.zfs_type, B_TRUE))
			return (zfs_error(hdl, EZFS_INVALIDNAME, errbuf));
	} else {
		if (recursive) {
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "recursive rename must be a snapshot"));
			return (zfs_error(hdl, EZFS_BADTYPE, errbuf));
		}

		if (!zfs_validate_name(hdl, target, zhp.zfs_type, B_TRUE))
			return (zfs_error(hdl, EZFS_INVALIDNAME, errbuf));

		// validate parents
		if (check_parents(hdl, target, null, B_FALSE, null) != 0)
			return (-1);

		//  make sure we're in the same pool
		verify((delim = strchr(target, '/')) !is null);
		if (strncmp(zhp.zfs_name, target, delim - target) != 0 ||
		    zhp.zfs_name[delim - target] != '/') {
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "datasets must be within same pool"));
			return (zfs_error(hdl, EZFS_CROSSTARGET, errbuf));
		}

		// new name cannot be a child of the current dataset name
		if (is_descendant(zhp.zfs_name, target)) {
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "New dataset name cannot be a descendant of "
			    "current dataset name"));
			return (zfs_error(hdl, EZFS_INVALIDNAME, errbuf));
		}
	}

	snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN, "cannot rename '%s'"), zhp.zfs_name);

	if (getzoneid() == GLOBAL_ZONEID && zfs_prop_get_int(zhp, ZFS_PROP_ZONED))
	{
		zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "dataset is used in a non-global zone"));
		return (zfs_error(hdl, EZFS_ZONED, errbuf));
	}

	if (recursive)
	{
		zfs_handle_t *zhrp;
		char *parentname = zfs_strdup(zhp.zfs_hdl, zhp.zfs_name);
		if (parentname is null) {
			ret = -1;
			goto error;
		}
		delim = strchr(parentname, '@');
		*delim = '\0';
		zhrp = zfs_open(zhp.zfs_hdl, parentname, ZFS_TYPE_DATASET);
		free(parentname);
		if (zhrp is null) {
			ret = -1;
			goto error;
		}
		zfs_close(zhrp);
	} else if (zhp.zfs_type != ZFS_TYPE_SNAPSHOT)
	{
		if ((cl = changelist_gather(zhp, ZFS_PROP_NAME, CL_GATHER_ITER_MOUNTED, force_unmount ? MS_FORCE : 0)) is null)
			return (-1);

		if (changelist_haszonedchild(cl))
		{
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "child dataset with inherited mountpoint is used " "in a non-global zone"));
			zfs_error(hdl, EZFS_ZONED, errbuf);
			ret = -1;
			goto error;
		}

		if ((ret = changelist_prefix(cl)) != 0)
			goto error;
	}

	if (ZFS_IS_VOLUME(zhp))
		zc.zc_objset_type = DMU_OST_ZVOL;
	else
		zc.zc_objset_type = DMU_OST_ZFS;

	strlcpy(zc.zc_name, zhp.zfs_name, sizeof (zc.zc_name));
	strlcpy(zc.zc_value, target, sizeof (zc.zc_value));

	zc.zc_cookie = recursive;

	if ((ret = zfs_ioctl(zhp.zfs_hdl, ZFS_IOC_RENAME, &zc)) != 0) {
		 // if it was recursive, the one that actually failed will be in zc.zc_name
		snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN, "cannot rename '%s'"), zc.zc_name);

		if (recursive && errno == EEXIST)
		{
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "a child dataset already has a snapshot with the new name"));
			zfs_error(hdl, EZFS_EXISTS, errbuf);
		} else if (errno == EACCES)
		{
			if (zfs_prop_get_int(zhp, ZFS_PROP_ENCRYPTION) ==
			    ZIO_CRYPT_OFF) {
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "cannot rename an unencrypted dataset to be a decendent of an encrypted one"));
			} else
			{
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "cannot move encryption child outside of its encryption root"));
			}
			zfs_error(hdl, EZFS_CRYPTOFAILED, errbuf);
		} else {
			zfs_standard_error(zhp.zfs_hdl, errno, errbuf);
		}

		// On failure, we still want to remount any filesystems that were previously mounted, so we don't alter the system state.
		if (cl !is null)
			changelist_postfix(cl);
	} else {
		if (cl !is null) {
			changelist_rename(cl, zfs_get_name(zhp), target);
			ret = changelist_postfix(cl);
		}
	}

error:
	if (cl !is null) {
		changelist_free(cl);
	}
	return (ret);
}

nvlist_t* getAllProperties(zfs_handle_t *zhp)
{
	return (zhp.zfs_props);
}

nvlist_t* getReceivedProperties(zfs_handle_t *zhp)
{
	if (zhp.zfs_recvd_props is null)
		if (get_recvd_props_ioctl(zhp) != 0)
			return (null);
	return (zhp.zfs_recvd_props);
}

nvlist_t* getUserProperties(zfs_handle_t *zhp)
{
	return (zhp.zfs_user_props);
}

/*
 * This function is used by 'zfs list' to determine the exact set of columns to
 * display, and their maximum widths.  This does two main things:
 *
 *      - If this is a list of all properties, then expand the list to include
 *        all native properties, and set a flag so that for each dataset we look
 *        for new unique user properties and add them to the list.
 *
 *      - For non fixed-width properties, keep track of the maximum width seen
 *        so that we can size the column appropriately. If the user has
 *        requested received property values, we also need to compute the width
 *        of the RECEIVED column.
 */
void expandPropertyList (zfs_handle_t *zhp, zprop_list_t **plp, bool received, bool literal)
{
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	zprop_list_t *entry;
	zprop_list_t **last, **start;
	nvlist_t *userprops, *propval;
	nvpair_t *elem;
	char *strval;
	char buf[ZFS_MAXPROPLEN];

	if (zprop_expand_list(hdl, plp, ZFS_TYPE_DATASET) != 0)
		return (-1);

	userprops = zfs_get_user_props(zhp);

	entry = *plp;
	if (entry.pl_all && nvlist_next_nvpair(userprops, null) !is null) {
		/*
		 * Go through and add any user properties as necessary.  We
		 * start by incrementing our list pointer to the first
		 * non-native property.
		 */
		start = plp;
		while (*start !is null) {
			if ((*start).pl_prop == ZPROP_INVAL)
				break;
			start = &(*start).pl_next;
		}

		elem = null;
		while ((elem = nvlist_next_nvpair(userprops, elem)) !is null) {
			/*
			 * See if we've already found this property in our list.
			 */
			for (last = start; *last !is null;
			    last = &(*last).pl_next) {
				if (strcmp((*last).pl_user_prop,
				    nvpair_name(elem)) == 0)
					break;
			}

			if (*last is null) {
				if ((entry = zfs_alloc(hdl,
				    sizeof (zprop_list_t))) is null ||
				    ((entry.pl_user_prop = zfs_strdup(hdl,
				    nvpair_name(elem)))) is null) {
					free(entry);
					return (-1);
				}

				entry.pl_prop = ZPROP_INVAL;
				entry.pl_width = strlen(nvpair_name(elem));
				entry.pl_all = B_TRUE;
				*last = entry;
			}
		}
	}

	/*
	 * Now go through and check the width of any non-fixed columns
	 */
	for (entry = *plp; entry !is null; entry = entry.pl_next) {
		if (entry.pl_fixed && !literal)
			continue;

		if (entry.pl_prop != ZPROP_INVAL) {
			if (zfs_prop_get(zhp, entry.pl_prop,
			    buf, sizeof (buf), null, null, 0, literal) == 0) {
				if (strlen(buf) > entry.pl_width)
					entry.pl_width = strlen(buf);
			}
			if (received && zfs_prop_get_recvd(zhp,
			    zfs_prop_to_name(entry.pl_prop),
			    buf, sizeof (buf), literal) == 0)
				if (strlen(buf) > entry.pl_recvd_width)
					entry.pl_recvd_width = strlen(buf);
		} else {
			if (nvlist_lookup_nvlist(userprops, entry.pl_user_prop,
			    &propval) == 0) {
				verify(nvlist_lookup_string(propval,
				    ZPROP_VALUE, &strval) == 0);
				if (strlen(strval) > entry.pl_width)
					entry.pl_width = strlen(strval);
			}
			if (received && zfs_prop_get_recvd(zhp,
			    entry.pl_user_prop,
			    buf, sizeof (buf), literal) == 0)
				if (strlen(buf) > entry.pl_recvd_width)
					entry.pl_recvd_width = strlen(buf);
		}
	}

	return (0);
}

void prunePropertyList(zfs_handle_t *zhp, uint8_t *props)
{
	nvpair_t *curr;
	nvpair_t *next;

	// Keep a reference to the props-table against which we prune the properties.
	zhp.zfs_props_table = props;
	curr = nvlist_next_nvpair(zhp.zfs_props, null);

	while (curr)
	{
		zfs_prop_t zfs_prop = zfs_name_to_prop(nvpair_name(curr));
		next = nvlist_next_nvpair(zhp.zfs_props, curr);

		 // User properties will result in ZPROP_INVAL, and since we only know how to prune
		 // standard ZFS properties, we always leave these in the list.  This can also happen if we
		 // encounter an unknown DSL property (when running older  software, for example).
		if (zfs_prop != ZPROP_INVAL && props[zfs_prop] == B_FALSE)
			nvlist_remove(zhp.zfs_props, nvpair_name(curr), nvpair_type(curr));
		curr = next;
	}
}

enum SmbAclOperation
{
	add = ZFS_SMB_ACL_ADD,
	remove = ZFS_SMB_ACL_REMOVE,
	rename = ZFS_SMB_ACL_RENAME,
	purge = ZFS_SMB_ACL_PURGE,
}


void smbAclManagement(string dataset, string path, SmbAclOperation operation, string resource1, strimng resource2)
{
	libzfs_handle_t *hdl = libZfsHandle;
	zfs_cmd_t zc = {"\0"};
	nvlist_t *nvlist = null;
	int error;

	safeCopy(zc.zc_name, zc.zc_name.sizeof, dataset);
	safeCopy(zc.zc_value,zc.zc_value.sizeof,path);
	zc.zc_cookie = operation.to!ulong;

	final switch(operation) with(SmbAclOperation)
	{
		case add,remove:
			safeCopy(zc.zc_string, zc.zc_string.sizeof,resource1);
			break;
		case rename:
			enforce(nvlist_alloc(&nvlist, NV_UNIQUE_NAME, 0)==0, oom());
			enforce(nvlist_add_string(nvlist, ZFS_SMB_ACL_SRC, resource1) == 0,oom());
			enforce(nvlist_add_string(nvlist, ZFS_SMB_ACL_TARGET, resource2) == 0,oom());
			scope(exit) nvlist_free(nvlist);
			enforce(zcmd_write_src_nvlist(hdl, &zc, nvlist) == 0,new ZfsException("operation failed"));
			break;
		case purge:
			break;
	}
	error = ioctl(hdl.libzfs_fd, ZFS_IOC_SMB_ACL, &zc);
	enforce(error == 0, new ZfsException(error, "smbAclManagement"));
}


void smblAclAdd(string dataset, string path, string resource)
{
	smbAclManagement(dataset,path,SmbAclOperation.add,resource,null);
}

void smbAclRemove(string dataset, string path, string resource)
{
	smbAclManagement(dataset, path, SmbAclOperation.remove,resource,null);
}


void smbAclPurge(string dataset, string path)
{
	smblAclManagement(dataset,path,SmblAclOperation.purge,null,null);
}

void smblAclRename(string dataset, string path, string oldName, string newName)
{
	smbAclManagement(dataset,path,SmbAclOperation.rename,oldName,newName);
}

int userSpace(zfs_handle_t *zhp, zfs_userquota_prop_t type, zfs_userspace_cb_t func, void *arg)
{
	zfs_cmd_t zc = {"\0"};
	zfs_useracct_t buf[100];
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	int ret;

	(void) strlcpy(zc.zc_name, zhp.zfs_name, sizeof (zc.zc_name));

	zc.zc_objset_type = type;
	zc.zc_nvlist_dst = (uintptr_t)buf;

	for (;;) {
		zfs_useracct_t *zua = buf;

		zc.zc_nvlist_dst_size = sizeof (buf);
		if (zfs_ioctl(hdl, ZFS_IOC_USERSPACE_MANY, &zc) != 0) {
			char errbuf[1024];

			if ((errno == ENOTSUP &&
			    (type == ZFS_PROP_USEROBJUSED ||
			    type == ZFS_PROP_GROUPOBJUSED ||
			    type == ZFS_PROP_USEROBJQUOTA ||
			    type == ZFS_PROP_GROUPOBJQUOTA ||
			    type == ZFS_PROP_PROJECTOBJUSED ||
			    type == ZFS_PROP_PROJECTOBJQUOTA ||
			    type == ZFS_PROP_PROJECTUSED ||
			    type == ZFS_PROP_PROJECTQUOTA)))
				break;

			(void) snprintf(errbuf, sizeof (errbuf),
			    dgettext(TEXT_DOMAIN,
			    "cannot get used/quota for %s"), zc.zc_name);
			return (zfs_standard_error_fmt(hdl, errno, errbuf));
		}
		if (zc.zc_nvlist_dst_size == 0)
			break;

		while (zc.zc_nvlist_dst_size > 0) {
			if ((ret = func(arg, zua.zu_domain, zua.zu_rid,
			    zua.zu_space)) != 0)
				return (ret);
			zua++;
			zc.zc_nvlist_dst_size -= sizeof (zfs_useracct_t);
		}
	}

	return (0);
}

struct holdarg {
	nvlist_t *nvl;
	const char *snapname;
	const char *tag;
	boolean_t recursive;
	int error;
};

void holdOne(zfs_handle_t *zhp, holdarg* ha)
{
	char[ZFS_MAX_DATASET_NAME_LEN] name;
	int rv = 0;

	if (snprintf(name, sizeof (name), "%s@%s", zhp.zfs_name, ha.snapname) >= sizeof (name))
		return (EINVAL);

	if (lzc_exists(name)) fnvlist_add_string(ha.nvl, name, ha.tag);
	if (ha.recursive)
		rv = zfs_iter_filesystems(zhp, zfs_hold_one, ha);
	zfs_close(zhp);
	return (rv);
}

void hold(zfs_handle_t *zhp, string snapshotName, string tag, bool recursive, int cleanup_fd)
{
	int ret;
	holdarg ha;
	ha.nvl = fnvlist_alloc();
	ha.snapname = snapname;
	ha.tag = tag;
	ha.recursive = recursive;
	(void) zfs_hold_one(zfs_handle_dup(zhp), &ha);

	if (nvlist_empty(ha.nvl))
	{
		char[1024] errbuf;

		fnvlist_free(ha.nvl);
		ret = ENOENT;
		snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN, "cannot hold snapshot '%s@%s'"), zhp.zfs_name, snapname);
		zfs_standard_error(zhp.zfs_hdl, ret, errbuf);
		return (ret);
	}

	ret = zfs_hold_nvl(zhp, cleanup_fd, ha.nvl);
	fnvlist_free(ha.nvl);

	return (ret);
}

vold hold(zfs_handle_t *zhp, int cleanup_fd, nvlist_t *holds)
{
	int ret;
	nvlist_t *errors;
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	char errbuf[1024];
	nvpair_t *elem;

	errors = null;
	ret = lzc_hold(holds, cleanup_fd, &errors);

	if (ret == 0) {
		/* There may be errors even in the success case. */
		fnvlist_free(errors);
		return (0);
	}

	if (nvlist_empty(errors)) {
		/* no hold-specific errors */
		(void) snprintf(errbuf, sizeof (errbuf),
		    dgettext(TEXT_DOMAIN, "cannot hold"));
		switch (ret) {
		case ENOTSUP:
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "pool must be upgraded"));
			(void) zfs_error(hdl, EZFS_BADVERSION, errbuf);
			break;
		case EINVAL:
			(void) zfs_error(hdl, EZFS_BADTYPE, errbuf);
			break;
		default:
			(void) zfs_standard_error(hdl, ret, errbuf);
		}
	}

	for (elem = nvlist_next_nvpair(errors, null);
	    elem !is null;
	    elem = nvlist_next_nvpair(errors, elem)) {
		(void) snprintf(errbuf, sizeof (errbuf),
		    dgettext(TEXT_DOMAIN,
		    "cannot hold snapshot '%s'"), nvpair_name(elem));
		switch (fnvpair_value_int32(elem)) {
		case E2BIG:
			/*
			 * Temporary tags wind up having the ds object id
			 * prepended. So even if we passed the length check
			 * above, it's still possible for the tag to wind
			 * up being slightly too long.
			 */
			(void) zfs_error(hdl, EZFS_TAGTOOLONG, errbuf);
			break;
		case EINVAL:
			(void) zfs_error(hdl, EZFS_BADTYPE, errbuf);
			break;
		case EEXIST:
			(void) zfs_error(hdl, EZFS_REFTAG_HOLD, errbuf);
			break;
		default:
			(void) zfs_standard_error(hdl,
			    fnvpair_value_int32(elem), errbuf);
		}
	}

	fnvlist_free(errors);
	return (ret);
}

void releaseOne(zfs_handle_t *zhp, void *arg)
{
	struct holdarg *ha = arg;
	char name[ZFS_MAX_DATASET_NAME_LEN];
	int rv = 0;
	nvlist_t *existing_holds;

	if (snprintf(name, sizeof (name), "%s@%s", zhp.zfs_name,
	    ha.snapname) >= sizeof (name)) {
		ha.error = EINVAL;
		rv = EINVAL;
	}

	if (lzc_get_holds(name, &existing_holds) != 0) {
		ha.error = ENOENT;
	} else if (!nvlist_exists(existing_holds, ha.tag)) {
		ha.error = ESRCH;
	} else {
		nvlist_t *torelease = fnvlist_alloc();
		fnvlist_add_boolean(torelease, ha.tag);
		fnvlist_add_nvlist(ha.nvl, name, torelease);
		fnvlist_free(torelease);
	}

	if (ha.recursive)
		rv = zfs_iter_filesystems(zhp, zfs_release_one, ha);
	zfs_close(zhp);
	return (rv);
}

void release(zfs_handle_t *zhp, string snapshotName, string tag, bool recursive)
{
	int ret;
	struct holdarg ha;
	nvlist_t *errors = null;
	nvpair_t *elem;
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	char errbuf[1024];

	ha.nvl = fnvlist_alloc();
	ha.snapname = snapname;
	ha.tag = tag;
	ha.recursive = recursive;
	ha.error = 0;
	zfs_release_one(zfs_handle_dup(zhp), &ha);

	if (nvlist_empty(ha.nvl)) {
		fnvlist_free(ha.nvl);
		ret = ha.error;
		snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN, "cannot release hold from snapshot '%s@%s'"), zhp.zfs_name, snapname);
		if (ret == ESRCH) {
			zfs_error(hdl, EZFS_REFTAG_RELE, errbuf);
		} else {
			zfs_standard_error(hdl, ret, errbuf);
		}
		return (ret);
	}

	ret = lzc_release(ha.nvl, &errors);
	fnvlist_free(ha.nvl);

	if (ret == 0) {
		// There may be errors even in the success case.
		fnvlist_free(errors);
		return (0);
	}

	if (nvlist_empty(errors)) {
		// no hold-specific errors
		snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN, "cannot release"));
		switch (errno) {
		case ENOTSUP:
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN, "pool must be upgraded"));
			zfs_error(hdl, EZFS_BADVERSION, errbuf);
			break;
		default:
			zfs_standard_error_fmt(hdl, errno, errbuf);
		}
	}

	for (elem = nvlist_next_nvpair(errors, null);
	    elem !is null;
	    elem = nvlist_next_nvpair(errors, elem)) {
		snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN, "cannot release hold from snapshot '%s'"), nvpair_name(elem));
		switch (fnvpair_value_int32(elem)) {
		case ESRCH:
			(void) zfs_error(hdl, EZFS_REFTAG_RELE, errbuf);
			break;
		case EINVAL:
			(void) zfs_error(hdl, EZFS_BADTYPE, errbuf);
			break;
		default:
			(void) zfs_standard_error_fmt(hdl, fnvpair_value_int32(elem), errbuf);
		}
	}

	fnvlist_free(errors);
	return (ret);
}

Variable[string] getFilesystemACL(zfs_handle_t *zhp)
//, nvlist_t **nvl)
{
	zfs_cmd_t zc = {"\0"};
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	int nvsz = 2048;
	void *nvbuf;
	int err = 0;
	char errbuf[1024];

	enforce(zhp.zfs_type == ZfsType.volume || zhp.zfs_type == ZfsType.filesystem);

tryagain:

	nvbuf = malloc(nvsz);
	if (nvbuf is null) {
		err = (zfs_error(hdl, EZFS_NOMEM, strerror(errno)));
		goto out;
	}

	zc.zc_nvlist_dst_size = nvsz;
	zc.zc_nvlist_dst = (uintptr_t)nvbuf;

	strlcpy(zc.zc_name, zhp.zfs_name, sizeof (zc.zc_name));

	if (ioctl(hdl.libzfs_fd, ZFS_IOC_GET_FSACL, &zc) != 0)
	{
		snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN, "cannot get permissions on '%s'"), zc.zc_name);
		switch (errno)
		{
			case ENOMEM:
				free(nvbuf);
				nvsz = zc.zc_nvlist_dst_size;
				goto tryagain;

			case ENOTSUP:
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
					"pool must be upgraded"));
				err = zfs_error(hdl, EZFS_BADVERSION, errbuf);
				break;
			case EINVAL:
				err = zfs_error(hdl, EZFS_BADTYPE, errbuf);
				break;
			case ENOENT:
				err = zfs_error(hdl, EZFS_NOENT, errbuf);
				break;
			default:
				err = zfs_standard_error_fmt(hdl, errno, errbuf);
				break;
		}
	} else {
		// success
		int rc = nvlist_unpack(nvbuf, zc.zc_nvlist_dst_size, nvl, 0);
		if (rc)
		{
			snprintf(errbuf, sizeof (errbuf), dgettext( TEXT_DOMAIN, "cannot get permissions on '%s'"), zc.zc_name);
			err = zfs_standard_error_fmt(hdl, rc, errbuf);
		}
	}

	free(nvbuf);
out:
	return (err);
}

void setFilesystemACL(zfs_handle_t *zhp, bool un, Variable[string] properties) // nvlist_t *nvl)
{
	zfs_cmd_t zc = {"\0"};
	libzfs_handle_t *hdl = zhp.zfs_hdl;
	char *nvbuf;
	char errbuf[1024];
	size_t nvsz;
	int err;

	enforce(zhp.zfs_type == ZfsType.volume || zhp.zfs_type == ZfsType.filesystem);
	err = nvlist_size(nvl, &nvsz, NV_ENCODE_NATIVE);
	enforce(err == 0);

	nvbuf = malloc(nvsz);

	err = nvlist_pack(nvl, &nvbuf, &nvsz, NV_ENCODE_NATIVE, 0);
	enforce(err == 0);

	zc.zc_nvlist_src_size = nvsz;
	zc.zc_nvlist_src = (uintptr_t)nvbuf;
	zc.zc_perm_action = un;

	strlcpy(zc.zc_name, zhp.zfs_name, sizeof (zc.zc_name));

	if (zfs_ioctl(hdl, ZFS_IOC_SET_FSACL, &zc) != 0)
	{
		snprintf(errbuf, sizeof (errbuf), dgettext(TEXT_DOMAIN, "cannot set permissions on '%s'"), zc.zc_name);
		switch (errno)
		{
			case ENOTSUP:
				zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
					"pool must be upgraded"));
				err = zfs_error(hdl, EZFS_BADVERSION, errbuf);
				break;
			case EINVAL:
				err = zfs_error(hdl, EZFS_BADTYPE, errbuf);
				break;
			case ENOENT:
				err = zfs_error(hdl, EZFS_NOENT, errbuf);
				break;
			default:
				err = zfs_standard_error_fmt(hdl, errno, errbuf);
				break;
		}
	}
	free(nvbuf);
	return (err);
}

Variable getHolds(zfs_handle_t *zhp)
{
	nvlist_t** nvl;
	char errbuf[1024];

	int err = lzc_get_holds(zhp.zfs_name, nvl);

	if (err != 0) {
		libzfs_handle_t *hdl = zhp.zfs_hdl;

		(void) snprintf(errbuf, sizeof (errbuf),
		    dgettext(TEXT_DOMAIN, "cannot get holds for '%s'"),
		    zhp.zfs_name);
		switch (err) {
		case ENOTSUP:
			zfs_error_aux(hdl, dgettext(TEXT_DOMAIN,
			    "pool must be upgraded"));
			err = zfs_error(hdl, EZFS_BADVERSION, errbuf);
			break;
		case EINVAL:
			err = zfs_error(hdl, EZFS_BADTYPE, errbuf);
			break;
		case ENOENT:
			err = zfs_error(hdl, EZFS_NOENT, errbuf);
			break;
		default:
			err = zfs_standard_error_fmt(hdl, errno, errbuf);
			break;
		}
	}

	return (err);
}

@Sildoc(`Convert the zvol's volume size to an appropriate reservation. Note: If this routine is updated, it is necessary to update the ZFS test suite's shell version in reservation.kshlib.`)
ulong zvolVolumeSizeToReservation(ulong volumeSize, Variable[] properties)
{
	ulong numdb;
	ulong nblocks, volblocksize;
	int ncopies;
	string strval;

	if (nvlist_lookup_string(props, zfs_prop_to_name(ZFS_PROP_COPIES), &strval) == 0)
		ncopies = atoi(strval);
	else
		ncopies = 1;
	if (nvlist_lookup_uint64(props, zfs_prop_to_name(ZFS_PROP_VOLBLOCKSIZE), &volblocksize) != 0)
		volblocksize = ZVOL_DEFAULT_BLOCKSIZE;
	nblocks = volsize/volblocksize;
	// start with metadnode L0-L6
	numdb = 7;
	// calculate number of indirects
	while (nblocks > 1)
	{
		nblocks += DNODES_PER_LEVEL - 1;
		nblocks /= DNODES_PER_LEVEL;
		numdb += nblocks;
	}
	numdb *= MIN(SPA_DVAS_PER_BP, ncopies + 1);
	volsize *= ncopies;
	// this is exactly DN_MAX_INDBLKSHIFT when metadata isn't compressed, but in practice they compress down to about  1100 bytes
	numdb *= 1ULL << DN_MAX_INDBLKSHIFT;
	volsize += numdb;
	return (volsize);
}

ZfsMountShareResult zfsMountAndShare(string datasetName, zfs_type_t type)
{
	zfs_handle_t* zhp = zfs_open(libZfsHandle, dataset, type);
	if (zhp is null)
		return ZfsMountShareResult.cannotOpen;

	scope(exit)
		zfs_close(zhp);

	// Volumes may neither be mounted or shared.  Potentially in the future filesystems detected on these volumes could be mounted.
	if (zfs_get_type(zhp) == ZFS_TYPE_VOLUME) {
		return ZfsMountShareResult.cannotDoForVolume;
	}

	// Mount and/or share the new filesystem as appropriate.  We provide a verbose error message to let the user
	// know that their filesystem was in fact created, even if we failed to mount or share it.
	// If the user doesn't want the dataset automatically mounted, then  skip the mount/share step

	if (zfs_prop_valid_for_type(ZFS_PROP_CANMOUNT, type, B_FALSE) && propertyGetT!ulong(zhp, ZFS_PROP_CANMOUNT) == ZFS_CANMOUNT_ON)
	{
		if (geteuid() != 0)
			return ZfsMountShareResult.successfullyCreatedButOnlyRootCanMount;
		if (zfs_mount(zhp, null, 0) != 0)
			return ZfsMountShareResult.successfullyCreatedButNotMounted;
		if (zfs_share(zhp) != 0)
			return ZfsMountShareResult.successfullyCreatedButNotShared;
	}
	return ZfsMountShareResult.success;
}

struct MountEntry
{
	string devicePath;
	string mountPath;
	string type;
	string[] flags;
	int arg1;
	int arg2;
}

MountEntry parseMount(string[] cols)
{
	if (cols.length < 6)
	{
		infof("dubious mount entry: %s",cols);
		return MountEntry.init;
	}

	MountEntry ret = {		devicePath:cols[0],
							mountPath:cols[1],
							type:cols[2],
							flags:cols[3].split(','),
							arg1:cols[4].to!int,
							arg2:cols[5].to!int, };
	return ret;
}

MountEntry[] getMounts()
{
	import std.file:readText;
	import std.string:splitLines, strip;
	import std.algorithm:map;
	import std.array:array;

	return 	readText("/proc/self/mounts")
				.splitLines
				.map!(line => line.strip)
				.filter!(line => line.length > 0)
				.map!(line => line.split(' ').parseMount)
				.array;
}

bool isSnapshot(MountEntry entry)
{
	import std.algorithm:canFind;
	return (entry.devicePath.canFind("@"));
}

 tank3/shared/kaleidic/develop /tank3/shared/kaleidic/develop zfs rw,xattr,noacl 0 0
 tank3/shared/kaleidic/symmetry /tank3/shared/kaleidic/symmetry zfs rw,xattr,noacl 0 0
 tank3/shared/kaleidic/symmetry/projects /tank3/shared/kaleidic/symmetry/projects zfs rw,xattr,noacl 0 0


enum Operation
{
	unshare,
	unmount,
}

enum Protocol
{
	nfs,
	smb,
}

@SILdoc(`unshare or unmount a filesystem`)
void unshareOrUnmount(Operation operation, Protocol protocol, bool doAll, bool force)
{
	int do_all = doAll ? 1 :0;
	int flags = (force)? MS_FORCE : 0;
	int ret = 0;
	int c;
	zfs_handle_t *zhp;
	char[ZFS_MAXPROPLEN] nfs_mnt_prop, sharesmb;


	if (do_all) {
		/*
		 * We could make use of zfs_for_each() to walk all datasets in
		 * the system, but this would be very inefficient, especially
		 * since we would have to linearly search /proc/self/mounts for
		 * each one. Instead, do one pass through /proc/self/mounts
		 * looking for zfs entries and call zfs_unmount() for each one.
		 *
		 * Things get a little tricky if the administrator has created
		 * mountpoints beneath other ZFS filesystems.  In this case, we
		 * have to unmount the deepest filesystems first.  To accomplish
		 * this, we place all the mountpoints in an AVL tree sorted by
		 * the special type (dataset name), and walk the result in
		 * reverse to make sure to get any snapshots first.
		 */
		struct mnttab entry;
		uu_avl_pool_t *pool;
		uu_avl_t *tree = null;
		unshare_unmount_node_t *node;
		uu_avl_index_t idx;
		uu_avl_walk_t *walk;
		char *protocol = null;


		if (((pool = uu_avl_pool_create("unmount_pool", unshare_unmount_node_t.sizeof,
		    offsetof(unshare_unmount_node_t, un_avlnode), unshare_unmount_compare, UU_DEFAULT))  is null) ||
		    ((tree = uu_avl_create(pool, null, UU_DEFAULT))  is null))
			nomem();

		foreach(entry;getMounts().filter!(entry => entry.type == "zfs" && !entry.isSnapshot))
		{
			if ((zhp = zfs_open(g_zfs, entry.mnt_special, ZFS_TYPE_FILESYSTEM))  is null) {
				ret = 1;
				continue;
			}

			 // Ignore datasets that are excluded/restricted by parent pool name.
			if (zpool_skip_pool(zfs_get_pool_name(zhp))) {
				zfs_close(zhp);
				continue;
			}

			final switch (operation)
			{
				case unshare:
					auto nfsMountProperty = propertyGet(zhp, ZFS_PROP_SHARENFS, null, null, 0, false);
					if (nfsMountProperty == "off")
						break;
					nfsMountProperty = propertyGet(zhp, ZFS_PROP_SHARESMB, null, null, 0, false);
					if (nfsMountProperty == "off")
						continue;
					break;

				case unmount:
					// Ignore legacy mounts
					auto nfsMountProperty = propertyGet(zhp, ZFS_PROP_MOUNTPOINT, null, null, 0, false);
					if (nfsMountProperty == "legacy")
						continue;
					// Ignore canmount=noauto mounts
					if (propertyGetT!ulong(zhp, ZFS_PROP_CANMOUNT) == ZFS_CANMOUNT_NOAUTO)
						continue;
			}

			node = theAllocator.make!unshare_unmount_node_t;
			node.un_zhp = zhp;
			node.un_mountp = safe_strdup(entry.mnt_mountp);

			uu_avl_node_init(node, &node.un_avlnode, pool);

			if (uu_avl_find(tree, node, null, &idx)  is null) {
				uu_avl_insert(tree, node, idx);
			} else {
				zfs_close(node.un_zhp);
				free(node.un_mountp);
				free(node);
			}
		}

		/*
		 * Walk the AVL tree in reverse, unmounting each filesystem and
		 * removing it from the AVL tree in the process.
		 */
		enforce((walk = uu_avl_walk_start(tree, UU_WALK_REVERSE | UU_WALK_ROBUST))  !is null, "memory allocation");
		while ((node = uu_avl_walk_next(walk)) !is null)
		{
			uu_avl_remove(tree, node);

			final switch (operation) with(Operation)
			{
				case unshare:
					if (zfs_unshareall_bytype(node.un_zhp, node.un_mountp, protocol) != 0)
						ret = 1;
					break;

				case unmount:
					if (zfs_unmount(node.un_zhp, node.un_zhp.zfs_name, flags) != 0)
						ret = 1;
					break;
			}

			zfs_close(node.un_zhp);
			free(node.un_mountp);
			free(node);
		}

		uu_avl_walk_end(walk);
		uu_avl_destroy(tree);
		uu_avl_pool_destroy(pool);

	} else
	{

		/*
		 * We have an argument, but it may be a full path or a ZFS
		 * filesystem.  Pass full paths off to unmount_path() (shared by
		 * manual_unmount), otherwise open the filesystem and pass to
		 * zfs_unmount().
		 */
		if (argv[0][0] == '/')
			return (unshare_unmount_path(op, argv[0], flags, B_FALSE));

		if ((zhp = zfs_open(g_zfs, argv[0], ZFS_TYPE_FILESYSTEM))  is null)
			return (1);

		auto nfsMountProperty = propertyGet(zhp, (operation == Operation.share)?  ZFS_PROP_SHARENFS : ZFS_PROP_MOUNTPOINT, null, null, 0, false);

		final switch (operation) with(Operation)
		{
			case unshare:
				auto nfsMountProperty = propertyGet(zhp, ZFS_PROP_SHARENFS, null, null, 0, false);
				auto smbShareProperty = propertyGet(zhp, ZFS_PROP_SHARESMB,  null, null, 0, false);

				if (nfsMountProperty == "off" && smbShareProperty == "off")
				{
					errorf("cannot unshare '%s': legacy share", zfs_get_name(zhp));
					errorf("use unshare(1M) to unshare this filesystem");
					ret = 1;
				} else if (!zfs_is_shared(zhp)) {
					errorf(gettext("cannot unshare '%s': not currently shared"), zfs_get_name(zhp));
					ret = 1;
				} else if (zfs_unshareall(zhp) != 0) {
					ret = 1;
				}
				break;

			case unmount:
				if (strcmp(nfs_mnt_prop, "legacy") == 0) {
					errorf("cannot unmount '%s': legacy mountpoint", zfs_get_name(zhp));
					errorf("use umount(1M) to unmount this filesystem");
					ret = 1;
				} else if (!zfs_is_mounted(zhp, null)) {
					errorf("cannot unmount '%s': not currently mounted", zfs_get_name(zhp));
					ret = 1;
			} else if (zfs_unmountall(zhp, flags) != 0) {
				ret = 1;
			}
			break;
		}

		zfs_close(zhp);
	}

	return (ret);
}


/*
 * zfs get [-rHp] [-o all | field[,field]...] [-s source[,source]...]
 *	< all | property[,property]... > < fs | snap | vol > ...
 *
 *	-r	recurse over any child datasets
 *	-H	scripted mode.  Headers are stripped, and fields are separated
 *		by tabs instead of spaces.
 *	-o	Set of fields to display.  One of "name,property,value,
 *		received,source". Default is "name,property,value,source".
 *		"all" is an alias for all five.
 *	-s	Set of sources to allow.  One of
 *		"local,default,inherited,received,temporary,none".  Default is
 *		all six.
 *	-p	Display values in parsable (literal) format.
 *
 *  Prints properties for the given datasets.  The user can control which
 *  columns to display as well as which property types to allow.
 */

/*
 * Invoked to display the properties for a single dataset.
 */

enum ZfsPropertySourceType
{
	none = ZPROP_SRC_NONE,
	local = ZPROP_SRC_LOCAL,
	received = ZPROP_SRC_RECEIVED,
	inherited = ZPROP_SRC_INHERITED,
}

enum ZfsPropertyType
{
	userQuota,
	written,
}

auto getPropertyUserQuota(void* userProperty)
{
	if (zfs_prop_userquote(pl.pl_user_prop))
	{
		return UserProperty(ZfsPropertySourceType.local, '-'.repeat(FieldLength).array);
	}
	if (zfs_prop_get_userquota(zhp, pl.pl_user_prop, buf, sizeof (buf), cbp.cb_literal) != 0) {
			sourcetype = ZPROP_SRC_NONE;
			buf = '-'.repeat(buf.sizeof).array;
			}
			zprop_print_one_property(zfs_get_name(zhp), cbp, pl.pl_user_prop, buf, sourcetype, source, null);
}

auto getPropertyWritten(void* userProperty, const(char)* cbLiteral)
{
	char[ZFS_MAXPROPLEN] buf;
	enforce(zfs_prop_written(userProperty) !is null);
	auto sourcetype = ZfsPropertySourceType.local;

	if (zfs_prop_get_written(zhp, userProperty, buf, buf.sizeof, cbLiteral) != 0)
	{
		sourcetype = ZfsPropertySourceType.none;
		buf = '-'.repeat(buf.sizeof).array;
	}
	return formatOneProperty(zfs_get_name(zhp), cbp, userProperty, buf, sourcetype, source, null);
}


int getCallback(zfs_handle_t *zhp, void *data)
{
	char[ZFS_MAXPROPLEN] buf;
	char[ZFS_MAXPROPLEN] rbuf;
	zprop_source_t sourcetype;
	char[ZFS_MAX_DATASET_NAME_LEN] source;
	zprop_get_cbdata_t *cbp = data;
	nvlist_t *user_props = zfs_get_user_props(zhp);
	zprop_list_t *pl = cbp.cb_proplist;
	nvlist_t *propval;
	char *strval;
	char *sourceval;
	boolean_t received = is_recvd_column(cbp);

	for (; pl !is null; pl = pl.pl_next)
	{
		char *recvdval = null;
		/*
		 * Skip the special fake placeholder.  This will also skip over
		 * the name property when 'all' is specified.
		 */
		if (pl.pl_prop == ZFS_PROP_NAME && pl == cbp.cb_proplist)
			continue;

		if (pl.pl_prop != ZPROP_INVAL) {
			if (zfs_prop_get(zhp, pl.pl_prop, buf, buf.sizeof, &sourcetype, source, source.sizeof, cbp.cb_literal) != 0) {
				if (pl.pl_all)
					continue;
				if (!zfs_prop_valid_for_type(pl.pl_prop, ZFS_TYPE_DATASET, B_FALSE)) {
					errorf("No such property '%s'",zfs_prop_to_name(pl.pl_prop));
					continue;
				}
				sourcetype = ZPROP_SRC_NONE;
				buf = '-'.repeat(buf.sizeof);
			}

			if (received && (zfs_prop_get_recvd(zhp,
			    zfs_prop_to_name(pl.pl_prop), rbuf, sizeof (rbuf),
			    cbp.cb_literal) == 0))
				recvdval = rbuf;

			zprop_print_one_property(zfs_get_name(zhp), cbp,
			    zfs_prop_to_name(pl.pl_prop),
			    buf, sourcetype, source, recvdval);
		} else if (zfs_prop_userquota(pl.pl_user_prop)) {
			sourcetype = ZPROP_SRC_LOCAL;

			if (zfs_prop_get_userquota(zhp, pl.pl_user_prop, buf, sizeof (buf), cbp.cb_literal) != 0) {
				sourcetype = ZPROP_SRC_NONE;
				buf = '-'.repeat(buf.sizeof).array;
			}
			zprop_print_one_property(zfs_get_name(zhp), cbp, pl.pl_user_prop, buf, sourcetype, source, null);
		} else if (zfs_prop_written(pl.pl_user_prop)) {
			sourcetype = ZPROP_SRC_LOCAL;

			if (zfs_prop_get_written(zhp, pl.pl_user_prop,
			    buf, sizeof (buf), cbp.cb_literal) != 0) {
				sourcetype = ZPROP_SRC_NONE;
				buf = '-'.repeat(buf.sizeof).array;
			}

			zprop_print_one_property(zfs_get_name(zhp), cbp,
			    pl.pl_user_prop, buf, sourcetype, source, null);
		} else {
			if (nvlist_lookup_nvlist(user_props,
			    pl.pl_user_prop, &propval) != 0) {
				if (pl.pl_all)
					continue;
				sourcetype = ZPROP_SRC_NONE;
				strval = "-";
			} else {
				verify(nvlist_lookup_string(propval,
				    ZPROP_VALUE, &strval) == 0);
				verify(nvlist_lookup_string(propval,
				    ZPROP_SOURCE, &sourceval) == 0);

				if (strcmp(sourceval,
				    zfs_get_name(zhp)) == 0) {
					sourcetype = ZPROP_SRC_LOCAL;
				} else if (strcmp(sourceval,
				    ZPROP_SOURCE_VAL_RECVD) == 0) {
					sourcetype = ZPROP_SRC_RECEIVED;
				} else {
					sourcetype = ZPROP_SRC_INHERITED;
					(void) strlcpy(source,
					    sourceval, sizeof (source));
				}
			}

			if (received && (zfs_prop_get_recvd(zhp,
			    pl.pl_user_prop, rbuf, sizeof (rbuf),
			    cbp.cb_literal) == 0))
				recvdval = rbuf;

			zprop_print_one_property(zfs_get_name(zhp), cbp,
			    pl.pl_user_prop, strval, sourcetype,
			    source, recvdval);
		}
	}

	return (0);
}

int zfsDoGet(bool cbLiteral = false, // p argument
			int limit = 0, // d argument
			bool recurse = false,
			bool cb_scripted)
{
	zprop_get_cbdata_t cb = { 0 };
	cb.cb_scripted = scripted ? 1 : 0;
	int i, c;
	int flags = ZFS_ITER_ARGS_CAN_BE_PATHS | (recurse ? ZFS_ITER_RECURSE : 0);
	int types = ZFS_TYPE_DATASET | ZFS_TYPE_BOOKMARK;
	char *value, *fields;
	int ret = 0;
	int limit = 0;
	zprop_list_t fake_name = { 0 };

	/*
	 * Set up default columns and sources.
	 */
	cb.cb_sources = ZPROP_SRC_ALL;
	cb.cb_columns[0] = GET_COL_NAME;
	cb.cb_columns[1] = GET_COL_PROPERTY;
	cb.cb_columns[2] = GET_COL_VALUE;
	cb.cb_columns[3] = GET_COL_SOURCE;
	cb.cb_type = ZFS_TYPE_DATASET;

	/* check options */
	while ((c = getopt(argc, argv, ":d:o:s:rt:Hp")) != -1) {
		switch (c) {
			break;
		case 'o':
			/*
			 * Process the set of columns to display.  We zero out
			 * the structure to give us a blank slate.
			 */
			bzero(&cb.cb_columns, sizeof (cb.cb_columns));
			i = 0;
			while (*optarg != '\0') {
				static char *col_subopts[] =
				    { "name", "property", "value", "received",
				    "source", "all", null };

				if (i == ZFS_GET_NCOLS) {
					errorf(gettext("too "
					    "many fields given to -o "
					    "option\n"));
					usage(B_FALSE);
				}

				switch (getsubopt(&optarg, col_subopts,
				    &value)) {
				case 0:
					cb.cb_columns[i++] = GET_COL_NAME;
					break;
				case 1:
					cb.cb_columns[i++] = GET_COL_PROPERTY;
					break;
				case 2:
					cb.cb_columns[i++] = GET_COL_VALUE;
					break;
				case 3:
					cb.cb_columns[i++] = GET_COL_RECVD;
					flags |= ZFS_ITER_RECVD_PROPS;
					break;
				case 4:
					cb.cb_columns[i++] = GET_COL_SOURCE;
					break;
				case 5:
					if (i > 0) {
						errorf(
						    gettext("\"all\" conflicts "
						    "with specific fields "
						    "given to -o option\n"));
						usage(B_FALSE);
					}
					cb.cb_columns[0] = GET_COL_NAME;
					cb.cb_columns[1] = GET_COL_PROPERTY;
					cb.cb_columns[2] = GET_COL_VALUE;
					cb.cb_columns[3] = GET_COL_RECVD;
					cb.cb_columns[4] = GET_COL_SOURCE;
					flags |= ZFS_ITER_RECVD_PROPS;
					i = ZFS_GET_NCOLS;
					break;
				default:
					errorf(
					    gettext("invalid column name "
					    "'%s'\n"), value);
					usage(B_FALSE);
				}
			}
			break;


	// Handle users who want to get all snapshots of the current dataset (ex. 'zfs get -t snapshot refer <dataset>').
	if (types == ZFS_TYPE_SNAPSHOT && argc > 1 && (flags & ZFS_ITER_RECURSE) == 0 && limit == 0)
	{
		flags |= (ZFS_ITER_DEPTH_LIMIT | ZFS_ITER_RECURSE);
		limit = 1;
	}

	if (zprop_get_list(g_zfs, fields, &cb.cb_proplist, ZFS_TYPE_DATASET) != 0)
		usage(B_FALSE);

	/*
	 * As part of zfs_expand_proplist(), we keep track of the maximum column
	 * width for each property.  For the 'NAME' (and 'SOURCE') columns, we
	 * need to know the maximum name length.  However, the user likely did
	 * not specify 'name' as one of the properties to fetch, so we need to
	 * make sure we always include at least this property for
	 * print_get_headers() to work properly.
	 */
	if (cb.cb_proplist !is null)
	{
		fake_name.pl_prop = ZFS_PROP_NAME;
		fake_name.pl_width = strlen(gettext("NAME"));
		fake_name.pl_next = cb.cb_proplist;
		cb.cb_proplist = &fake_name;
	}

	cb.cb_first = B_TRUE;

	/* run for each object */
	ret = zfs_for_each(argc, argv, flags, types, null,
	    &cb.cb_proplist, limit, getCallback, &cb);

	if (cb.cb_proplist == &fake_name)
		zprop_free_list(fake_name.pl_next);
	else
		zprop_free_list(cb.cb_proplist);

	return (ret);
}

/*
 * inherit [-rS] <property> <fs|vol> ...
 *
 *	-r	Recurse over all children
 *	-S	Revert to received value, if any
 *
 * For each dataset specified on the command line, inherit the given property
 * from its parent.  Inheriting a property at the pool level will cause it to
 * use the default value.  The '-r' flag will recurse over all children, and is
 * useful for setting a property on a hierarchy-wide basis, regardless of any
 * local modifications for each dataset.
 */

struct inheritCallbackdata_t
{
	const(char)* *cb_propname;
	boolean_t cb_received;
}


int inheritRecurseCallback(zfs_handle_t *zhp, void *data)
{
	inheritCallbackdata_t *cb = data;
	zfs_prop_t prop = zfs_name_to_prop(cb.cb_propname);

	/*
	 * If we're doing it recursively, then ignore properties that
	 * are not valid for this type of dataset.
	 */
	if (prop != ZPROP_INVAL &&
	    !zfs_prop_valid_for_type(prop, zfs_get_type(zhp), B_FALSE))
		return (0);

	return (zfs_prop_inherit(zhp, cb.cb_propname, cb.cb_received) != 0);
}

int inheritCallback(zfs_handle_t *zhp, void *data)
{
	inheritCallbackdata_t *cb = data;

	return (zfs_prop_inherit(zhp, cb.cb_propname, cb.cb_received) != 0);
}

int zfsDoInherit(int argc, char **argv)
{
	int c;
	zfs_prop_t prop;
	inheritCallbackdata_t cb = { 0 };
	char *propname;
	int ret = 0;
	int flags = 0;
	boolean_t received = B_FALSE;

	/* check options */
	while ((c = getopt(argc, argv, "rS")) != -1) {
		switch (c) {
		case 'r':
			flags |= ZFS_ITER_RECURSE;
			break;
		case 'S':
			received = B_TRUE;
			break;
		case '?':
		default:
			errorf(gettext("invalid option '%c'\n"),
			    optopt);
			usage(B_FALSE);
		}
	}

	argc -= optind;
	argv += optind;

	/* check number of arguments */
	if (argc < 1) {
		errorf(gettext("missing property argument\n"));
		usage(B_FALSE);
	}
	if (argc < 2) {
		errorf(gettext("missing dataset argument\n"));
		usage(B_FALSE);
	}

	propname = argv[0];
	argc--;
	argv++;

	if ((prop = zfs_name_to_prop(propname)) != ZPROP_INVAL) {
		if (zfs_prop_readonly(prop)) {
			errorf(gettext(
			    "%s property is read-only\n"),
			    propname);
			return (1);
		}
		if (!zfs_prop_inheritable(prop) && !received) {
			errorf("'%s' property cannot be inherited"), propname);
			if (prop == ZFS_PROP_QUOTA ||
			    prop == ZFS_PROP_RESERVATION ||
			    prop == ZFS_PROP_REFQUOTA ||
			    prop == ZFS_PROP_REFRESERVATION) {
				errorf("use 'zfs set %s=none' to clear"), propname);
				errorf("use 'zfs inherit -S %s' to revert to received value", propname);
			}
			return (1);
		}
		if (received && (prop == ZFS_PROP_VOLSIZE ||
		    prop == ZFS_PROP_VERSION)) {
			errorf(gettext("'%s' property cannot "
			    "be reverted to a received value\n"), propname);
			return (1);
		}
	} else if (!zfs_prop_user(propname)) {
		errorf(gettext("invalid property '%s'\n"),
		    propname);
		usage(B_FALSE);
	}

	cb.cb_propname = propname;
	cb.cb_received = received;

	if (flags & ZFS_ITER_RECURSE) {
		ret = zfs_for_each(argc, argv, flags, ZFS_TYPE_DATASET, null, null, 0, inheritRecurseCallback, &cb);
	} else {
		ret = zfs_for_each(argc, argv, flags, ZFS_TYPE_DATASET,
		    null, null, 0, inheritCallback, &cb);
	}

	return (ret);
}

struct UpgradeCallbackData
{
	ulong numupgraded;
	ulong numsamegraded;
	ulong numfailed;
	ulong version;
	bool newer;
	bool foundone;
	char[ZFS_MAX_DATASET_NAME_LEN] cb_lastfs;
}

bool isSamePool(zfs_handle_t *zhp, string poolName)
{
	int len1 = strcspn(name.toCString, "/@");
	const(char)* *zhname = zfs_get_name(zhp);
	int len2 = strcspn(zhname, "/@");

	if (len1 != len2)
		return false;
	return (strncmp(name, zhname, len1) == 0);
}

int upgradeListCallback(zfs_handle_t *zhp, void *data)
{
	upgrade_cbdata_t *cb = data;
	int version_ = zfs_prop_get_int(zhp, ZFS_PROP_VERSION);

	// list if it's old/new
	if ((!cb.cb_newer && version_ < ZPL_VERSION) || (cb.cb_newer && version_ > ZPL_VERSION)) {
		auto s = (cb.cb_newer) ?
			"The following filesystems are formatted using a newer software version and\n" ~
			"cannot be accessed on the current system.\n\n" :

			"The following filesystems are out of date, and can be upgraded.  After being\n" ~
			"upgraded, these filesystems (and any 'zfs send' streams generated from\n" ~
			"subsequent snapshots) will no longer be accessible by older software versions.\n\n";

		if (!cb.cb_foundone) {
			infof(s);
			infof("VER  FILESYSTEM");
			infof("---  ------------");
			cb.cb_foundone = B_TRUE;
		}

		infof("%2u   %s\n", version_, zfs_get_name(zhp));
	}
	return 0;
}

int upgradeSetCallback(zfs_handle_t *zhp, void *data)
{
	auto cb = cast(UpgradeCallbackData*) data;
	int version_ = propertyGetInteger(zhp, ZFS_PROP_VERSION);
	int spa_version = spaVersion(zhp);
	enforce(spa_version >=0);
	int needed_spa_version = zfs_spa_version_map(cb.cb_version);
	enforce(needed_spa_version >=0);
	if (spa_version < needed_spa_version)
	{
		errorf("%s: can not be " "upgraded; the pool version needs to first be upgraded\nto version %d\n\n"), zfs_get_name(zhp), needed_spa_version);
		cb.numfailed++;
		return 0;
	}

	// upgrade
	if (version_ < cb.version_)
	{
		char verstr[16];
		(void) snprintf(verstr, sizeof (verstr), "%llu", (u_longlong_t)cb.cb_version);
		if (cb.cb_lastfs[0] && !same_pool(zhp, cb.cb_lastfs))
		{
			/*
			 * If they did "zfs upgrade -a", then we could
			 * be doing ioctls to different pools.  We need
			 * to log this history once to each pool, and bypass
			 * the normal history logging that happens in main().
			 */
			zpool_log_history(g_zfs, history_str);
			log_history = B_FALSE;
		}
		if (propertySet(zhp, "version", verstr) == 0)
			cb.cb_numupgraded++;
		else
			cb.cb_numfailed++;
		(void) strcpy(cb.cb_lastfs, zfs_get_name(zhp));
	} else if (version_ > cb.version_)
	{
		// can't downgrade
		errorf("%s: can not be downgraded; it is already at version %u\n", zfs_get_name(zhp), version_);
		cb.numfailed++;
	} else
	{
		cb.numsamegraded++;
	}
	return (0);
}

@SILdoc(`upgrade ZFS filesystem`)
int zfsDoUpgrade(bool recursive, bool all = false)
{
	int ret = 0;
	upgrade_cbdata_t cb = { 0 };
	int c;
	int flags = ZFS_ITER_ARGS_CAN_BE_PATHS;
	if (recursive)
		flags |= ZFS_ITER_RECURSE;

	/* check options */
	case 'V':
		if (zfs_prop_string_to_index(ZFS_PROP_VERSION, optarg, &cb.cb_version) != 0) {
			errorf("invalid version %s", optarg);
			usage(B_FALSE);
			}


	// Upgrade filesystems
	cb.cb_version = (cb.cb_version == 0) ?  ZPL_VERSION : cb.cb_version;

	ret = zfs_for_each(argc, argv, flags, ZFS_TYPE_FILESYSTEM, null, null, 0, upgradeSetCallback, &cb);
	infof("%s filesystems upgraded", cb.cb_numupgraded);
	if (cb.cb_numsamegraded)
		infof("%llu filesystems already at this version", cb.cb_numsamegraded);
	
	return (cb.cb_numfailed != 0) ? 1 : -1;
}

@SILdoc(`get ZFS Version`)
string getZfsVersion()
{
	import std.format:format;
	return format!"%llu."(ZPL_VERSION);
}


@SILdoc(`List old-version filesystems`)
string[] listOldVersionFilesystems()
{
	bool found;
	int flags i= ZFS_ITER_ARGS_CAN_BE_PATHS | ZFS_ITER_RECURSE;
	ret = zfs_for_each(0, null, flags, ZFS_TYPE_FILESYSTEM, null, null, 0, upgradeListCallback, &cb);

	found = cb.cb_foundone;
	cb.cb_foundone = B_FALSE;
	cb.cb_newer = B_TRUE;

	ret = zfs_for_each(0, null, flags, ZFS_TYPE_FILESYSTEM, null, null, 0, upgradeListCallback, &cb);
	if (!cb.cb_foundone && !found) {
			infof("All filesystems are formatted with the current version.");
		}
	}
	return ret;
}

