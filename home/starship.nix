{pkgs, ...}: {
  enable = true;
  enableZshIntegration = true;
  settings = {
    format = ''
      [╭─](white)$username$hostname in $directory$package$git_branch$git_commit$nodejs$docker_context$battery$cmd_duration
      [╰─](white)$character
    '';
    add_newline = false;
    package = {
      disabled = true;
    };
  };
}
