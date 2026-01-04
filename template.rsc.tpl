#!rsc by RouterOS
# RouterOS script: <script-filename>
# Copyright (c) <year> Philip 'ShokiNN' Henning <mail@philip-henning.com>
# https://git.s1q.dev/phg/routeros-scripts-custom/about/COPYING.md
#
# requires RouterOS, version=<min ros version>
#
# <short script description>
# https://git.s1q.dev/phg/routeros-scripts-custom/about/doc/<script-filename>.md

:local ExitOK false;
onerror Err {
  :global GlobalConfigReady; :global GlobalFunctionsReady;
  :retry { :if ($GlobalConfigReady != true || $GlobalFunctionsReady != true) \
      do={ :error ("Global config and/or functions not ready."); }; } delay=500ms max=50;
  :local ScriptName [ :jobname ];

  :global LogPrint;
  :global ScriptFromTerminal;
  :global SendNotification2;

  # Log notifications locally, or send them via email/pushover etc. when not run from terminal
  # Usually used for important notifications only
  :if ([ $ScriptFromTerminal $ScriptName ] = true) do={
    # Add Script from here for running from terminal:
    $LogPrint info $ScriptName ("Hello world!");
  } else={
    # Add Script from here for running as scheduled script:
    $SendNotification2 ({ origin=$ScriptName; subject="Hello..."; message="... world!" });
  }
} do={
  :global ExitError; $ExitError $ExitOK [ :jobname ] $Err;
}
