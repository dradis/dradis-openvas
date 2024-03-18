module Dradis::Plugins::OpenVAS
  module Mapping
    DEFAULT_MAPPING = {
      evidence: {
        'Port' => '{{ openvas[evidence.port] }}',
        'Description' => '{{ openvas[evidence.description] }}'
      },
      result: {
        'Title' => '{{ openvas[result.name] }}',
        'CVSSv2' => '{{ openvas[result.cvss_base] }}',
        'AffectedSoftware' => '{{ openvas[result.affected_software] }}',
        'Description' => '{{ openvas[result.summary] }}',
        'Recommendation' => '{{ openvas[result.solution] }}',
        'References' => "CVE: {{ openvas[result.cve] }}\n
                        CVSS Vector: {{ cvss_base_vector }}\n
                        BID: {{ openvas[result.bid] }}\n
                        Other: {{ openvas[result.xref] }}",
        'RawDescription' => "(note that some of the information below can change from instance to instance of this problem)\n
                            {{ openvas[result.description] }}"
      }
    }.freeze
  end
end
