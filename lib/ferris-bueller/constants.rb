module FerrisBueller
  module Constants
    RETRY_DELAY = 5

    RESOLVED_TRANSITIONS = %w[ 51 ]

    RESOLVED_STATE = /resolve/i

    CLOSED_TRANSITIONS = %w[ 61 71 ]

    CLOSED_STATE = /close/i

    SEVERITIES = {
      1 => '10480',
      2 => '10481',
      3 => '10482',
      4 => '10483',
      5 => '10484'
    }

    SHOW_FIELDS = {
      'summary' => 'Summary',
      'description' => 'Description',
      'customfield_11250' => 'Severity',
      'customfield_11251' => 'Impact Started',
      'customfield_11252' => 'Impact Ended',
      'customfield_11253' => 'Reported By',
      'customfield_11254' => 'Services Affected',
      'customfield_11255' => 'Cause',
      'status' => 'Status',
      'created' => 'Created',
      'updated' => 'Updated'
    }

    SEVERITY_FIELD = SHOW_FIELDS.key('Severity')
    HELP_TEXT = '
/inc help - print this message
/inc resolve <inc> - resolve incident number <inc>
/inc close <inc> - close incident number <inc>
/inc whoami - test to see if bueller can tell who you are
/inc list - list incidents
/inc summary - summary of incidents
/inc show <inc> - show incident info for incident <inc>
/inc comment <inc> <comment> - comment on incident <inc> with comment <comment>
/inc open <severity> <summary> - open incident with severity of 1(high)-5(low) <severity>
'
  end
end
