program stakeholder_fortran
  implicit none
  integer :: argc, i, seed, status
  character(len=128) :: arg, value, output_format, focus_family, provider
  logical :: list_values

  output_format = 'text'
  focus_family = ''
  provider = ''
  seed = 42
  list_values = .false.
  argc = command_argument_count()
  i = 1
  do while (i <= argc)
    call get_command_argument(i, arg)
    select case (trim(arg))
    case ('--list-values')
      list_values = .true.
      i = i + 1
    case ('--focus-family')
      call require_value(i, argc, '--focus-family', value)
      focus_family = normalize_family(value)
      i = i + 2
    case ('--output-format')
      call require_value(i, argc, '--output-format', value)
      if (trim(value) /= 'text' .and. trim(value) /= 'json') call fail('unsupported --output-format: '//trim(value), 2)
      output_format = trim(value)
      i = i + 2
    case ('--seed')
      call require_value(i, argc, '--seed', value)
      read(value, *, iostat=status) seed
      if (status /= 0) seed = 42
      i = i + 2
    case ('--experimental-provider')
      call require_value(i, argc, '--experimental-provider', provider)
      call fail("fortran-stakeholder: experimental provider '"//trim(provider)//"' is not implemented in Tranche D; gap=fortran.experimental-provider-fail-fast", 2)
    case ('--project', '-p', '--dev-type', '-d', '--jargon', '-j', '--complexity', '-c', '--framework', '-F', '--duration', '-T')
      call require_value(i, argc, trim(arg), value)
      i = i + 2
    case ('--alerts', '-a', '--team', '-t', '--trace', '--minimal', '--no-color')
      i = i + 1
    case ('--help', '-h')
      print '(a)', 'fortran-stakeholder [--list-values] [--focus-family FAMILY] [--output-format text|json] [--seed N] [--experimental-provider PROVIDER]'
      stop 0
    case default
      if (index(trim(arg), '--experimental-') == 1) then
        call fail('experimental flags require --experimental-provider. gap=fortran.experimental-provider-fail-fast', 2)
      else
        call fail('unknown argument: '//trim(arg), 2)
      end if
    end select
  end do

  if (list_values) then
    call emit_list_values()
  else
    if (len_trim(focus_family) > 0) then
      if (.not. known_family(trim(focus_family))) call fail('unsupported --focus-family: '//trim(focus_family), 2)
      if (trim(output_format) == 'json') then
        call emit_json(trim(focus_family), seed)
      else
        call emit_text(trim(focus_family), seed)
      end if
    else
      if (trim(output_format) == 'json') then
        call emit_json(default_family(seed), seed)
      else
        call emit_text(default_family(seed), seed)
      end if
    end if
  end if
contains
  subroutine require_value(index_arg, argc_arg, flag, out)
    integer, intent(in) :: index_arg, argc_arg
    character(len=*), intent(in) :: flag
    character(len=*), intent(out) :: out
    if (index_arg + 1 > argc_arg) call fail('missing value for '//trim(flag), 2)
    call get_command_argument(index_arg + 1, out)
    if (index(trim(out), '--') == 1) call fail('missing value for '//trim(flag), 2)
  end subroutine

  subroutine fail(message, code)
    character(len=*), intent(in) :: message
    integer, intent(in) :: code
    write(error_unit(), '(a)') trim(message)
    call exit(code)
  end subroutine

  integer function error_unit()
    error_unit = 0
  end function

  function normalize_family(input) result(out)
    character(len=*), intent(in) :: input
    character(len=128) :: out
    integer :: j
    out = input
    do j = 1, len_trim(out)
      if (out(j:j) == '_') out(j:j) = '-'
    end do
  end function

  function family_key(input) result(out)
    character(len=*), intent(in) :: input
    character(len=128) :: out
    integer :: j
    out = input
    do j = 1, len_trim(out)
      if (out(j:j) == '-') out(j:j) = '_'
    end do
  end function

  logical function known_family(family)
    character(len=*), intent(in) :: family
    known_family = parity_class(family) /= 'unknown'
  end function

  function default_family(seed_value) result(family)
    integer, intent(in) :: seed_value
    character(len=128) :: family
    character(len=40), parameter :: classic(6) = [character(len=40) :: 'code-analyzer', 'data-processing', 'jargon', 'metrics', 'network-activity', 'system-monitoring']
    family = classic(mod(abs(seed_value), 6) + 1)
  end function

  function parity_class(family) result(cls)
    character(len=*), intent(in) :: family
    character(len=32) :: cls
    select case (trim(family))
    case ('code-analyzer','data-processing','jargon','metrics','network-activity','system-monitoring')
      cls = 'classic-six'
    case ('agent-workflows','platform-engineering','observability-ai-runtime','delivery-preview-ops','supply-chain-security')
      cls = 'modern-core'
    case ('ai-inference-ops','evaluation-and-guardrails','knowledge-retrieval','edge-client-runtime','identity-and-trust','aibom-provenance','agent-boundary-security','embedded-agentic-pipeline','data-governance-compliance','finops-capacity','blockchain-protocol-ops','cross-chain-interop','proof-and-sequencer-ops','hybrid-runtime-ops','capacity-cost-controller','batch-execution-tuner','compiler-maintainer','interop-adapter-engineer','preflight-capacity-planner','simulator-performance-engineer','fhir-profile-generator','smart-launch-oauth','bulk-fhir-population-ops','hl7v2-feed-ops','clinical-workflow-events','dicomweb-imaging-ops','openehr-semantic-record-ops','device-telemetry-clinical','emr-vendor-adapter','ocpp-chargepoint-ops','ocpi-roaming-ops','mcp-a2a-ops','streaming-bus-ops','service-mesh-rpc-ops')
      cls = 'grouped-fallback'
    case default
      cls = 'unknown'
    end select
  end function

  function message_for(family) result(message)
    character(len=*), intent(in) :: family
    character(len=256) :: message
    select case (trim(family))
    case ('code-analyzer')
      message = 'scanning source modules for reviewable complexity and dependency movement'
    case ('data-processing')
      message = 'batching records through deterministic transforms and stable output ordering'
    case ('jargon')
      message = 'keeping technical language current without drifting into fake-deep jargon'
    case ('metrics')
      message = 'tracking queue depth latency bands and cost signals across the active workload'
    case ('network-activity')
      message = 'observing RPC event-stream and adapter traffic across the current service boundary'
    case ('system-monitoring')
      message = 'watching collector pressure runner health and process saturation on the active stack'
    case ('agent-workflows')
      message = 'routing coding-agent work through review queues and approval gates'
    case ('platform-engineering')
      message = 'maintaining golden paths service templates and workload identity'
    case ('observability-ai-runtime')
      message = 'recording traces token spend and latency bands for the active runtime'
    case ('delivery-preview-ops')
      message = 'managing preview environments feature flags and canary promotions'
    case ('supply-chain-security')
      message = 'checking artifact trust secret exposure and dependency health before release'
    case default
      message = 'holding later-family behavior behind an explicit grouped fallback'
    end select
  end function

  subroutine emit_list_values()
    character(len=40), parameter :: families(45) = [character(len=40) :: 'code-analyzer','data-processing','jargon','metrics','network-activity','system-monitoring','agent-workflows','platform-engineering','observability-ai-runtime','delivery-preview-ops','supply-chain-security','ai-inference-ops','evaluation-and-guardrails','knowledge-retrieval','edge-client-runtime','identity-and-trust','aibom-provenance','agent-boundary-security','embedded-agentic-pipeline','data-governance-compliance','finops-capacity','blockchain-protocol-ops','cross-chain-interop','proof-and-sequencer-ops','hybrid-runtime-ops','capacity-cost-controller','batch-execution-tuner','compiler-maintainer','interop-adapter-engineer','preflight-capacity-planner','simulator-performance-engineer','fhir-profile-generator','smart-launch-oauth','bulk-fhir-population-ops','hl7v2-feed-ops','clinical-workflow-events','dicomweb-imaging-ops','openehr-semantic-record-ops','device-telemetry-clinical','emr-vendor-adapter','ocpp-chargepoint-ops','ocpi-roaming-ops','mcp-a2a-ops','streaming-bus-ops','service-mesh-rpc-ops']
    integer :: j
    write(*,'(a)', advance='no') '{"language":"fortran","renderer":"fortran-stakeholder","families":['
    do j = 1, size(families)
      if (j > 1) write(*,'(a)', advance='no') ','
      write(*,'(a)', advance='no') '"'//trim(families(j))//'"'
    end do
    write(*,'(a)') ']}'
  end subroutine

  subroutine emit_json(family, seed_value)
    character(len=*), intent(in) :: family
    integer, intent(in) :: seed_value
    write(*,'(a)', advance='no') '{"language":"fortran","renderer":"fortran-stakeholder","seed":'
    write(*,'(i0)', advance='no') seed_value
    write(*,'(a)', advance='no') ',"events":[{"family":"'//trim(family)//'","familyKey":"'//trim(family_key(family))//'","parityClass":"'//trim(parity_class(family))//'","sequence":1,"timestamp":"T+000137ms","message":"'
    write(*,'(a)', advance='no') trim(message_for(family))
    write(*,'(a)') '","metadata":{"schemaVersion":"2026-04","contract":"classic-six-plus-modern-core"}}]}'
  end subroutine

  subroutine emit_text(family, seed_value)
    character(len=*), intent(in) :: family
    integer, intent(in) :: seed_value
    write(*,'(a,i0,a,a,a,a)') 'fortran-stakeholder seed=', seed_value, ' family=', trim(family), ' parity=', trim(parity_class(family))
    write(*,'(a)') trim(message_for(family))
  end subroutine
end program
