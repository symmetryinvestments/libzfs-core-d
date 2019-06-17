bool bookmarkExists(string path)
{
	nvlist_t *bmarks;
	nvlist_t *props;
	char[ZFS_MAX_DATASET_NAME_LEN] fsname;
	char *bmark_name;
	char *pound;
	int err;
	boolean_t rv;

	if (!path.canFind("#"))
		return false;
	(void) strlcpy(fsname, path, sizeof (fsname));
	pound = strchr(fsname, '#');
	if (pound is null)
		return (B_FALSE);

	*pound = '\0';
	bmark_name = pound + 1;
	props = fnvlist_alloc();
	err = lzc_get_bookmarks(fsname, props, &bmarks);
	nvlist_free(props);
	if (err != 0) {
		nvlist_free(bmarks);
		return (B_FALSE);
	}

	rv = nvlist_exists(bmarks, bmark_name);
	nvlist_free(bmarks);
	return (rv);
}

zfs_handle_t* makeBookmarkHandle(zfs_handle_t *parent, string path, nvlist_t *bmark_props)
{
	zfs_handle_t *zhp = calloc(1, sizeof (zfs_handle_t));
	enforce(zhp !is null, "memory allocation");

	// Fill in the name.
	zhp.zfs_hdl = parent.zfs_hdl;
	(void) strlcpy(zhp.zfs_name, path, sizeof (zhp.zfs_name));

	// Set the property lists.
	if (nvlist_dup(bmark_props, &zhp.zfs_props, 0) != 0) {
		free(zhp);
		return null;
	}

	// Set the types
	zhp.zfs_head_type = parent.zfs_head_type;
	zhp.zfs_type = ZFS_TYPE_BOOKMARK;

	if ((zhp.zpool_hdl = zpool_handle(zhp)) is null) {
		nvlist_free(zhp.zfs_props);
		free(zhp);
		return null;
	}
	return (zhp);
}

struct zfs_open_bookmarks_cb_data
{
	string path;
	zfs_handle_t* zhp;
}

static int openBookmarksCallBack zfs_open_bookmarks_cb(zfs_handle_t *zhp, void *data)
{
	struct zfs_open_bookmarks_cb_data *dp = data;

	/*
	 * Is it the one we are looking for?
	 */
	if (strcmp(dp.path, zfs_get_name(zhp)) == 0) {
		/*
		 * We found it.  Save it and let the caller know we are done.
		 */
		dp.zhp = zhp;
		return (EEXIST);
	}

	/*
	 * Not found.  Close the handle and ask for another one.
	 */
	zfs_close(zhp);
	return (0);
}

