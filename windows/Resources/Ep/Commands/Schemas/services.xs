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
     <xs:element ref="Error" />
     <xs:element ref="Services" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Services">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Service" minOccurs="0" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="lptimestamp"     type="xs:dateTime" /> <!-- use="required" /> -->
  </xs:complexType>
 </xs:element>

 <xs:element name="Service">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="ServiceType" />
    <xs:element ref="AcceptedCodes" />
   </xs:sequence>
    <xs:attribute name="name" 		type="xs:string"		use="required"/>
    <xs:attribute name="displayName"	type="xs:string"		use="required"/>
    <xs:attribute name="state"		type="xs:nonNegativeInteger"	use="required"/>
  </xs:complexType>
 </xs:element>

 <xs:element name="ServiceType">
  <xs:complexType>
   <xs:sequence>
    <xs:element form="qualified" minOccurs="0" name="SERVICE_WIN32_OWN_PROCESS" />
    <xs:element form="qualified" minOccurs="0" name="SERVICE_WIN32_SHARE_PROCESS" />
    <xs:element form="qualified" minOccurs="0" name="SERVICE_KERNEL_DRIVER" />
    <xs:element form="qualified" minOccurs="0" name="SERVICE_FILE_SYSTEM_DRIVER" />
    <xs:element form="qualified" minOccurs="0" name="SERVICE_INTERACTIVE_PROCESS" />
   </xs:sequence>
   <xs:attribute name="value" type="feHex" use="required"/>
  </xs:complexType>
 </xs:element>

 <xs:element name="AcceptedCodes">
  <xs:complexType>
   <xs:sequence>
    <xs:element form="qualified" minOccurs="0" name="SERVICE_ACCEPT_STOP" />
    <xs:element form="qualified" minOccurs="0" name="SERVICE_ACCEPT_PAUSE_CONTINUE" />
    <xs:element form="qualified" minOccurs="0" name="SERVICE_ACCEPT_SHUTDOWN" />
    <xs:element form="qualified" minOccurs="0" name="SERVICE_ACCEPT_PARAMCHANGE" />
    <xs:element form="qualified" minOccurs="0" name="SERVICE_ACCEPT_NETBINDCHANGE" />
    <xs:element form="qualified" minOccurs="0" name="SERVICE_ACCEPT_HARDWAREPROFILECHANGE" />
    <xs:element form="qualified" minOccurs="0" name="SERVICE_ACCEPT_POWEREVENT" />
   </xs:sequence>
   <xs:attribute name="value" type="feHex" use="required"/>
  </xs:complexType>
 </xs:element>

</xs:schema>
