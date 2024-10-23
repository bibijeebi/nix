{
  channels,
  namespace,
  inputs,
  ...
}: final: prev: {
  mkWindowsApp = inputs.erosanix.packages.${prev.system}.mkWindowsApp;
}
