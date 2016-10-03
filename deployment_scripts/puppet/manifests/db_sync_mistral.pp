#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral db_sync_mistral.pp')

class tesora_mistral::db_sync {

  Exec <| title == 'mistral-db-sync' |> {
    refreshonly => false,
  }

  Exec <| title == 'mistral-db-populate' |> {
    refreshonly => false,
  }

  include mistral::db::sync
}

class {'tesora_mistral::db_sync_mistral':}
