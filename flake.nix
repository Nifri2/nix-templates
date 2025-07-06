{
  description = "Custom Flake Templates :3";

  outputs = { self }: {
    templates = {
      go = {
        path = ./templates/go;
        description = "Go Project flake setup";
      };
      python = {
        path = ./templates/python;
        description = "Basic python setup with Nix";
      };
      micropython = {
        path = ./templates/micropython;
        description = "MicroPython project setup with Nix";
      };
    };
  };
}