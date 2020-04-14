#!/bin/sh

set -o errexit
set -o xtrace

bin/td_df eval 'Elixir.TdDf.Release.migrate()'
bin/td_df start
