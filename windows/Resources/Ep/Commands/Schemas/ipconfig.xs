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
     <xs:element ref="FixedData" />
     <xs:element ref="Adapter" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

  <xs:element name='FixedData'>
    <xs:complexType>
        <xs:sequence>
          <xs:element name='Type'          form="qualified" type="xs:string"/>
          <xs:element name='HostName'      form="qualified" type="xs:string"/>
          <xs:element name='DomainName'    form="qualified" type="xs:string"/>
          <xs:element name='ScopeId'       form="qualified" type="xs:string"/>
	  <xs:element name='EnableDns'     form="qualified" type="feEmptyElement" minOccurs="0"/>
	  <xs:element name='EnableProxy'   form="qualified" type="feEmptyElement" minOccurs="0"/>
	  <xs:element name='EnableRouting' form="qualified" type="feEmptyElement" minOccurs="0"/>
          <xs:element name='DnsServerList' form="qualified" type="IpSet" maxOccurs="unbounded"/>
        </xs:sequence>
        <xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name='Adapter'>
    <xs:complexType>
     <xs:sequence>
      <xs:element name='Name'          type="xs:string" form="qualified" />
      <xs:element name='Description'   type="xs:string" form="qualified" />
      <xs:element name='PrimaryWins'   type="IpSet"     form="qualified" />
      <xs:element name='SecondaryWins' type="IpSet"     form="qualified" />
      <xs:element name='DHCP'          type="IpSet"     form="qualified" />
      <xs:element name='Gateway'       type="IpSet"     form="qualified" />
      <xs:element name='Type'          type="xs:string" form="qualified" />
      <xs:element name="DhcpEnabled"                    form="qualified" minOccurs="0"/>
      <xs:element name="HaveWins"                       form="qualified" minOccurs="0"/>
      <xs:element ref="Lease" />
      <xs:element name='Address'       type="xs:string" form="qualified" />
      <xs:element name='AdapterIp'     type="IpSet"     form="qualified" maxOccurs="unbounded"/>
     </xs:sequence>

     <xs:attribute name='index' type='xs:nonNegativeInteger' use='required'/>
     <xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name="Lease">
   <xs:complexType>
    <xs:sequence>
     <xs:element name="Obtained" type="TimeStamp" form="qualified" />
     <xs:element name="Expires"  type="TimeStamp" form="qualified" />
    </xs:sequence>
   </xs:complexType>
  </xs:element>

  <xs:complexType name="TimeStamp">
   <xs:simpleContent>
    <xs:extension base="xs:dateTime">
     <xs:attribute name="locale" type="localeType"/>
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>

  <xs:complexType name="IpSet">
   <xs:sequence>
    <xs:element name="IP"   form="qualified" type="xs:string" minOccurs="0" />
    <xs:element name="Mask" form="qualified" type="xs:string" minOccurs="0" />
   </xs:sequence>
  </xs:complexType>

<!-- Types -->
 <xs:simpleType name='localeType'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value='remotelocal'/>
    <xs:enumeration value='remotegmt'/>
  </xs:restriction>
 </xs:simpleType>

</xs:schema>

