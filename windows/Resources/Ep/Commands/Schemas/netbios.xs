<?xml version="1.0"?>
<xs:schema targetNamespace="urn:ddb:expandingpulley"
           xmlns='urn:ddb:expandingpulley'           
           xmlns:xs="http://www.w3.org/2001/XMLSchema" >

 <xs:include schemaLocation="commonDefs.xs" />

 <xs:element name="Data">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Instance"  />
    <xs:element ref="Command"/>
    <xs:element ref="Autoload" minOccurs="0" maxOccurs="unbounded" />
    <xs:choice minOccurs="0" maxOccurs="unbounded">
     <xs:element ref="NetBios" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="NetBios">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="NCB" />
    <xs:element ref="Adapter" minOccurs="0" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="NCB">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="CallName" type="xs:string" form="qualified" />
    <xs:element name="NCBName" type="xs:string" form="qualified" />
   </xs:sequence>
   <xs:attribute name="ncb_command"  use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="ncb_retcode"  use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="ncb_lsn"      use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="ncb_num"      use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="ncb_rto"      use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="ncb_sto"      use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="ncb_lana_num" use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="ncb_cmd_cplt" use="required" type="xs:nonNegativeInteger" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Adapter">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Names" minOccurs="0" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="adapter_addr"      use="required" type="xs:string" />
   <xs:attribute name="adapter_type"      use="required" type="xs:string" />
   <xs:attribute name="release"           use="required" type="xs:float" />
   <xs:attribute name="duration"          use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="name_count"        use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="frame_recv"        use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="frame_xmit"        use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="iframe_recv_err"   use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="xmit_aborts"       use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="xmit_success"      use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="recv_success"      use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="iframe_xmit_err"   use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="recv_buff_unavail" use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="t1_timeouts"       use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="ti_timeouts"       use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="free_ncbs"         use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="max_dgram_size"    use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="max_sess_pkt_size" use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="pending_sess"      use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="max_cfg_sess"      use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="reserved0"         use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="reserved1"         use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="max_cfg_ncbs"      use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="max_ncbs"          use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="xmit_buf_unavail"  use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="max_sess"          use="required" type="xs:nonNegativeInteger" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Names">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Type"    type="xs:string" form="qualified" />
    <xs:element name="NetName" type="xs:string" form="qualified" />
    <xs:element name="Name"    type="xs:string" form="qualified" />
   </xs:sequence>
  </xs:complexType>
 </xs:element>

</xs:schema>
