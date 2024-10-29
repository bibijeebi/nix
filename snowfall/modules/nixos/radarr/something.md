

#+BEGIN_SRC json :tangle config.json
{
    "APIKey": "",
    "AnalyticsEnabled": true,
    "AuthenticationMethod": "None",
    "AuthenticationRequired": false,
    "DownloadClient": {
        "Enable": false,
        "RemotePathMappings": []
    },
    "EnableColorImpairedMode": false,
    "IgnoreCertificateErrors": false,
    "Indexer": {
        "AvailabilityDelay": 0,
        "MaximumSize": 0,
        "MinimumAge": 0,
        "Retention": 0
    },
    "LogDir": "/var/lib/radarr/.config/Radarr/logs",
    "LogLevel": "info",
    "MediaManagement": {
        "ColonReplacementFormat": "delete",
        "MovieFolders": [],
        "RenameMovies": true,
        "ReplaceIllegalCharacters": true,
        "UnmonitorDeletedMovies": false
    },
    "Theme": "auto",
    "UILanguage": "en",
    "UrlBase": ""
}
#+END_SRC

#+BEGIN_SRC xml :tangle config.xml
<Config>
  <BindAddress>*</BindAddress>
  <Port>7878</Port>
  <SslPort>9898</SslPort>
  <EnableSsl>False</EnableSsl>
  <LaunchBrowser>True</LaunchBrowser>
  <ApiKey>af19708ea7294869bafbd954a9c3595c</ApiKey>
  <AuthenticationMethod>Basic</AuthenticationMethod>
  <AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>
  <Branch>master</Branch>
  <LogLevel>debug</LogLevel>
  <SslCertPath></SslCertPath>
  <SslCertPassword></SslCertPassword>
  <UrlBase>crackshack.io</UrlBase>
  <InstanceName>Radarr</InstanceName>
  <Theme>dark</Theme>
</Config>
#+END_SRC
