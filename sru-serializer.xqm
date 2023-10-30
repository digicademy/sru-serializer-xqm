xquery version "3.1";

(:
 : MWB | SRU serializer
 :
 : Edited and developed by Patrick D. Brookshire and Ute Recker-Hamm
 : Academy of Sciences and Literature | Mainz
 :
 : xquery module containing various functions used to build OASIS-SRU related elements
 :
 : @author Patrick D. Brookshire
 : @licence MIT
:)

module namespace sru-serializer="http://mwb.adwmainz.net/exist/fcs/sru-serializer";


declare namespace scan = "http://docs.oasis-open.org/ns/search-ws/scan";
declare namespace sru = "http://www.loc.gov/zing/srw/";
declare namespace sruResponse = "http://docs.oasis-open.org/ns/search-ws/sruResponse";
declare namespace zr = "http://explain.z3950.org/dtd/2.0/";

declare variable $sru-serializer:default-query-type := "cql";
declare variable $sru-serializer:default-supported-versions := ("1.1", "1.2", "2.0");
declare variable $sru-serializer:basic-params := ("version", "operation", "query", "queryType", "scanClause");


(:~ builds a SRU element with the given params
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
 : @param $operation the value of the operation param
 : @param $element-name the name of the element to be built (without prefix!)
 : @param $content the content that should be wrapped by the element to be built
:)
declare function sru-serializer:get($version as xs:string, $operation as xs:string, $element-name as xs:string, $content as item()*) as element() {
    element {
        if (starts-with($version, "1.")) then
            QName("http://www.loc.gov/zing/srw/", "sru:" || $element-name)
        else if ($operation eq "scan") then
            QName("http://docs.oasis-open.org/ns/search-ws/scan", "scan:" || $element-name)
        else
            QName("http://docs.oasis-open.org/ns/search-ws/sruResponse", "sruResponse:" || $element-name)
    } { $content }
};

(:~ builds the QName for an element depending on the version (i.e. sru:{$element-name} for "1.1" and "1.2" or sruResponse:{$element-name} otherwise)
 : @param $element-name the name of the element without prefix
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
:)
declare %private function sru-serializer:build-response-qname($element-name as xs:string, $version as xs:string) as xs:QName {
    if (starts-with($version, "1.")) then
        QName("http://www.loc.gov/zing/srw/", "sru:" || $element-name)
    else
        QName("http://docs.oasis-open.org/ns/search-ws/sruResponse", "sruResponse:" || $element-name)
};

(:~ builds the QName for a diagnostic element depending on the version
 : @param $element-name the name of the element without prefix
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
:)
declare %private function sru-serializer:build-diagnostic-qname($element-name as xs:string, $version as xs:string) as xs:QName {
    if (starts-with($version, "1.")) then
        QName("http://www.loc.gov/zing/srw/diagnostic/", "diag:" || $element-name)
    else
        QName("http://docs.oasis-open.org/ns/search-ws/diagnostic", "diag:" || $element-name)
};

(:~ builds a SRU diagnostic element with the given params
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
 : @param $uri the URI of the diagnostic (e.g. "info:srw/diagnostic/1/1")
 : @param $details the details of the diagnostic
 : @param $message the message of the diagnostic
 : @see http://docs.oasis-open.org/search-ws/searchRetrieve/v1.0/os/part3-sru2.0/searchRetrieve-v1.0-os-part3-sru2.0.html#_Toc324162491
:)
declare function sru-serializer:get-diagnostic($version as xs:string, $uri as xs:string, $details as xs:string, $message as xs:string) as element(diagnostic) {
    element { sru-serializer:build-diagnostic-qname("diagnostic", $version) } {
        element { sru-serializer:build-diagnostic-qname("uri", $version) } { $uri },
        element { sru-serializer:build-diagnostic-qname("details", $version) } { $details },
        element { sru-serializer:build-diagnostic-qname("message", $version) } { $message }
    }
};

(:~ builds a SRU version element with the given version if it is allowed or a diagnostic
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
:)
declare function sru-serializer:get-version($version as xs:string) as element() {
    sru-serializer:get-version($version, $sru-serializer:default-supported-versions)
};

(:~ builds a SRU version element with the given version if it is allowed or a diagnostic
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
 : @param $supported-versions a sequence of versions that should not lead to a diagnostic
:)
declare function sru-serializer:get-version($version as xs:string, $supported-versions as xs:string*) as element() {
    if (starts-with($version, "1.")) then
        <sru:version>{ $version }</sru:version>
    else if ($version = $supported-versions) then
        <sruResponse:version>{ $version }</sruResponse:version>
    else
        sru-serializer:get-diagnostic($version, "info:srw/diagnostic/1/5", $version, "Unsupported version")
};


(:~ builds a SRU version element with the given version if it is allowed or a diagnostic
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
:)
declare function sru-serializer:get-scan-version($version as xs:string) as element() {
sru-serializer:get-scan-version($version, $sru-serializer:default-supported-versions)
};

(:~ builds a SRU version element with the given version if it is allowed or a diagnostic
: @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
: @param $supported-versions a sequence of versions that should not lead to a diagnostic
:)
declare function sru-serializer:get-scan-version($version as xs:string, $supported-versions as xs:string*) as element() {
if (starts-with($version, "1.")) then
    <sru:version>{ $version }</sru:version>
else if ($version = $supported-versions) then
    <scan:version>{ $version }</scan:version>
else
    sru-serializer:get-diagnostic($version, "info:srw/diagnostic/1/5", $version, "Unsupported version")
};

(:~ builds a SRU version element as used for echoed requests in SRU version "1.1" and "1.2"
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
:)
declare function sru-serializer:get-echoed-request-version($version as xs:string) as element(sru:version)? {
    if (starts-with($version, "1.")) then
        <sru:version>{ $version }</sru:version>
    else
        ()
};

(:~ builds a SRU explainResponse element with the given params and no extraResponseData elements
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
 : @param $content the elements that should follow the initial version element (Please note that diagnostic elements will automatically wrapped by a diagnostics element)
:)
declare function sru-serializer:get-explain-response($version as xs:string, $content as item()*) as element(explainResponse) {
    element { sru-serializer:build-response-qname("explainResponse", $version) } {
        sru-serializer:get-version($version),
        if (count($content/descendant-or-self::*:diagnostic) gt 0) then
            sru-serializer:get($version, "explain", "diagnostics", $content/descendant-or-self::*:diagnostic)
        else
            $content
    }
};

(:~ builds a SRU explainResponse element with the given params
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
 : @param $explain the main explain element
 : @param $extra-response-data the data to be wrapped by an extraResponseData element
:)
declare function sru-serializer:get-explain-response($version as xs:string, $explain as element(zr:explain), $extra-response-data as element()*) as element(explainResponse) {
    sru-serializer:get-explain-response($version, (
        sru-serializer:get-explain-record($version, $explain),
        if (starts-with($version, "1.")) then
            <sru:echoedExplainRequest>
                <sru:version>{ $version }</sru:version>
            </sru:echoedExplainRequest>
        else
            (),
        <sruResponse:extraResponseData>{ $extra-response-data }</sruResponse:extraResponseData>
    ))
};

(:~ builds a SRU scanResponse element with the given params
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
 : @param $content the elements that should follow the initial version element (Please note that diagnostic elements will automatically wrapped by a diagnostics element)
:)
declare function sru-serializer:get-scan-response($version as xs:string, $content as element()*) as element(scanResponse) {
    sru-serializer:get($version, "scan", "scanResponse", (
        sru-serializer:get-scan-version($version),
        if (count($content/descendant-or-self::*:diagnostic) gt 0) then
            sru-serializer:get($version, "scan", "diagnostics", $content/descendant-or-self::*:diagnostic)
        else
            $content
    ))
};

(:~ builds a SRU searchRetrieveResponse element with the given params
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
 : @param $content the elements that should follow the initial version element (Please note that diagnostic elements will automatically wrapped by a diagnostics element)
:)
declare function sru-serializer:get-search-retrieve-response($version as xs:string, $content as element()*) as element(searchRetrieveResponse) {
    element { sru-serializer:build-response-qname("searchRetrieveResponse", $version) } {
        sru-serializer:get-version($version),
        if (count($content/descendant-or-self::*:diagnostic) gt 0) then
            sru-serializer:get($version, "searchRetrieve", "diagnostics", $content/descendant-or-self::*:diagnostic)
        else
            $content
    }
};

(:~ builds a SRU record element with the given params
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
 : @param $data the content of the recordData element
 : @param $position the index no (started with 1) of the given hit in the result set
:)
declare function sru-serializer:get-record($version as xs:string, $data as element(), $position as xs:integer?) {
    element { sru-serializer:build-response-qname("record", $version) } {
        element { sru-serializer:build-response-qname("recordSchema", $version) } { "http://clarin.eu/fcs/resource" },
        if (starts-with($version, "1.")) then
            <sru:recordPacking>xml</sru:recordPacking>
        else
            <sruResponse:recordXMLEscaping>xml</sruResponse:recordXMLEscaping>,
        element { sru-serializer:build-response-qname("recordData", $version) } { $data },
        if ($position) then
            element { sru-serializer:build-response-qname("recordPosition", $version) } { $position }
        else
            ()
    }
};

(:~ builds a SRU record element for the explain API with the given params
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
 : @param $data the content of the recordData element
 : @param $position the index no (started with 1) of the given hit in the result set
:)
declare function sru-serializer:get-explain-record($version as xs:string, $data as element()) {
    element { sru-serializer:build-response-qname("record", $version) } {
        element { sru-serializer:build-response-qname("recordSchema", $version) } { "http://explain.z3950.org/dtd/2.0/" },
        if (starts-with($version, "1.")) then
            <sru:recordPacking>xml</sru:recordPacking>
        else
            <sruResponse:recordXMLEscaping>xml</sruResponse:recordXMLEscaping>,
        element { sru-serializer:build-response-qname("recordData", $version) } { $data }
    }
};

(:~ builds a SRU record element with the given params
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
 : @param $operation the value of the operation param
 : @param $params the name of all SRU params
:)
declare function sru-serializer:get-operation($version as xs:string, $operation as xs:string, $params as xs:string*) as xs:string {
    if (starts-with($version, "1.")) then
        $operation
    else
        if ($operation = ("explain", "scan", "searchRetrieve")) then
            $operation
        else if ($operation eq "") then
            (: guess operation from given params in Version 2.0 :)
            if ("scanClause" = $params) then
                "scan"
            else if ("query" = $params or "queryType" = $params) then
                "searchRetrieve"
            else
                "explain"
        else
            $operation
};

(:~ builds a SRU numberOfRecords element with the given params
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
 : @param $record-count the number of hits
:)
declare function sru-serializer:get-number-of-records($version as xs:string, $record-count as xs:integer) as element(numberOfRecords) {
    element { sru-serializer:build-response-qname("numberOfRecords", $version) } { $record-count }
};

(:~ builds a SRU nextRecordPosition element with the given params
 : @param $version the SRU version (should be one of ("1.1", "1.2", "2.0"))
 : @param $start-record the value of the SRU param startRecord
 : @param $maximum-records the value of the SRU param maximumRecords
 : @param $record-count the number of hits
:)
declare function sru-serializer:get-next-record-position($version as xs:string, $start-record as xs:integer, $maximum-records as xs:integer, $record-count as xs:integer) as element(nextRecordPosition)? {
    if ($start-record + $maximum-records <= $record-count) then
        element { sru-serializer:build-response-qname("nextRecordPosition", $version) } { $start-record + $maximum-records }
    else
        ()
};
