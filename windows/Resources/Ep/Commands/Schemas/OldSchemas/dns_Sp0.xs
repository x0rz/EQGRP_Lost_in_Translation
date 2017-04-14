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
     <xs:element ref="Dns" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Dns">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Response"           form="qualified" type="feEmptyElement" minOccurs="0" />
    <xs:element name="Authority"          form="qualified" type="feEmptyElement" minOccurs="0" />
    <xs:element name="Truncated"          form="qualified" type="feEmptyElement" minOccurs="0" />
    <xs:element name="RecursionAvailable" form="qualified" type="feEmptyElement" minOccurs="0" />
    <xs:element ref="ResponseCode" />
    <xs:element ref="QuestionData" />
    <xs:element ref="AnswerData" />
    <xs:element ref="NameServerData" />
    <xs:element ref="AdditionalRecordsData" />
   </xs:sequence>
   <xs:attribute name="id"     use="required" type="feHex" />
   <xs:attribute name="opCode" use="required" type="xs:string" />
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="QuestionData">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Question" form="qualified" maxOccurs="unbounded">
     <xs:complexType>
      <xs:sequence>
       <xs:element ref="String" minOccurs="0" maxOccurs="unbounded" />
       <xs:element name="Type" form="qualified" type="xs:string" />      
       <xs:element name="Class" form="qualified" type="xs:string" />      
      </xs:sequence>
     </xs:complexType>
    </xs:element>
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="AnswerData">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Answer" type="Resource" form="qualified"  maxOccurs="unbounded" minOccurs="0"/>
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="NameServerData">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="NameServer" type="Resource" form="qualified" maxOccurs="unbounded" minOccurs="0" />
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="AdditionalRecordsData">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="AdditionalData" type="Resource" form="qualified" maxOccurs="unbounded" minOccurs="0"/>
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:complexType name="Resource">
  <xs:sequence>
   <xs:element ref="String" minOccurs="0" maxOccurs="unbounded" />
   <xs:element name="TypeStr" form="qualified" type="xs:string" minOccurs="0" />
   <xs:element name="Type" form="qualified" type="feHex" minOccurs="0" />
   <xs:element name="Class" form="qualified" type="feHex" minOccurs="0" />
   <xs:element ref="DnsData" minOccurs="0" maxOccurs="unbounded" />
  </xs:sequence>
  <xs:attribute name="ttl" type="xs:nonNegativeInteger" use="optional" />
 </xs:complexType>

 <xs:element name="DnsData">
  <xs:complexType mixed="true">
  <xs:sequence>
   <xs:element ref="String" minOccurs="0" maxOccurs="unbounded" />
   <xs:element name="PrimaryNameServer" form="qualified" type="StringContainer" minOccurs="0"/>
   <xs:element name="ResponsibleMailbox" form="qualified" type="StringContainer" minOccurs="0"/>
   <xs:element name="Version" form="qualified" type="feHex" minOccurs="0"/>
   <xs:element name="RefreshInterval" form="qualified" type="feHex" minOccurs="0"/>
   <xs:element name="RetryInterval" form="qualified" type="feHex" minOccurs="0"/>
   <xs:element name="ExpirationLimit" form="qualified" type="feHex" minOccurs="0"/>
   <xs:element name="MinimumTTL" form="qualified" type="feHex" minOccurs="0"/>
	<xs:choice>
		<xs:element name="Preference" form="qualified" type="feHex" minOccurs="0"/>
		<xs:element name="Prefence" form="qualified" type="feHex" minOccurs="0"/>
	</xs:choice>	
   <xs:element name="ExchangeMailbox" form="qualified" type="StringContainer" minOccurs="0"/>
   <xs:element name="CPUType" form="qualified" type="StringContainer" minOccurs="0"/>
   <xs:element name="HostType" form="qualified" type="StringContainer" minOccurs="0"/>
   <xs:element name="RawData" form="qualified" type="xs:string" minOccurs="0"/>
  </xs:sequence>
  <xs:attribute name="unknownData" type="xs:boolean" use="optional"/>
  <xs:attribute name="type" type="xs:string" />
  </xs:complexType>
 </xs:element>

 <xs:complexType name="StringContainer">
  <xs:sequence>
   <xs:element ref="String" minOccurs="0" maxOccurs="unbounded" />
  </xs:sequence>
  <xs:attribute name="type" type="xs:string" />
 </xs:complexType>

 <xs:element name="String">
  <xs:complexType mixed="true">
   <xs:sequence>
    <xs:element ref="String" minOccurs="0" maxOccurs="unbounded" />
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="ResponseCode">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="code"     type="xs:nonNegativeInteger" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

</xs:schema>

