#!rsc by RouterOS
# RouterOS script: <script-filename>
# Copyright (c) <year> Philip 'ShokiNN' Henning <mail@philip-henning.com>
# https://git.s1q.dev/phg/routeros-scripts-custom/about/COPYING.md
#
# requires RouterOS, version=<min ros version>
#
# <short script description>
# https://git.s1q.dev/phg/routeros-scripts-custom/about/doc/<script-filename>.md

:global GlobalFunctionsReady;
:while ($GlobalFunctionsReady != true) do={ :delay 500ms; }

:local ExitOK false;
:do {
  :local ScriptName [ :jobname ];

  :global LogPrint;
  :global ParseKeyValueStore;
  :global ScriptLock;

  # Local/global script specific variables

  :if ([ $ScriptLock $ScriptName ] = false) do={
    :set ExitOK true;
    :error false;
  }

  # Add Script from here:

} on-error={
  :global ExitError; $ExitError $ExitOK [ :jobname ];
}