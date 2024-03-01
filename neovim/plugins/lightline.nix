{...}: {
  programs.nixvim.plugins.lightline = {
    enable = true;

    componentFunction = {
      readonly = "LightlineReadonly";
      fileformat = "LightlineFileformat";
      visual_words_and_chars = "VisualWordsAndChars";
      git_ps1_status = "GitPS1Status";
    };

    active = {
      left = [
        ["mode"]
        ["readonly" "git_ps1_status" "filename" "modified"]
      ];
      right = [
        ["lineinfo"]
        ["percent"]
        ["fileformat" "fileencoding" "filetype"]
        ["visual_words_and_chars"]
      ];
    };

    inactive = {
      left = [
        ["filename" "modified"]
      ];
      right = [
        ["lineinfo"]
        ["percent"]
      ];
    };
  };
}
