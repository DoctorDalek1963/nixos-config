config = {
    # Define wrapper styles for different parts of the filename.
    # Use '[]' for square brackets, '{}' for curly brackets, '()' for parentheses, or an empty string for None.
    "wrapper_styles": {
        "studio": '',
        "title": '',
        "performers": '',
        "date": '',
        "height": '[]',
        "video_codec": '[]',
        "frame_rate": '[]',
        "tag": '[]'
    },

    # Define the separator to use between different parts of the filename.
    # Use '-' for hyphen, '_' for underscore, or ' ' for space.
    "separator": ' - ',

    # Define the order of keys in the filename.
    # Use a list to specify the order of keys.
    # Valid keys are 'studio', 'title', 'performers', 'date', 'height', 'video_codec', 'frame_rate', and 'tags'.
    "key_order": [
        "studio",
        "title",
        "performers",
        # "date",
        # "height",
        # "video_codec",
        # "frame_rate",
        # "tags"
    ],

    # Define keys to exclude from the formed filename
    # Specify keys to exclude from the filename formation process. (ie. "exclude_keys": ["studio", "date"],)
    "exclude_keys": [],

    # Define whether files should be moved when renaming
    "move_files": False,

    # Define whether files should be renamed when moved
    "rename_files": True,

    # Define whether the script should run in dry run mode
    "dry_run": False,

    # Define the maximum number of tag keys to include in the filename (None for no limit)
    "max_tag_keys": 10,

    # Define a whitelist of allowed tags (None to disallow all tags)
    "tag_whitelist": [],

    # Define paths to exclude from modifications
    "exclude_paths": []
}
