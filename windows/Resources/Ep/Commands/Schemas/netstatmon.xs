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
     <xs:element ref="Connection" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice minOccurs="0">
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

  <xs:element name='Connection'>
    <xs:complexType>
	<xs:attribute name='type'       type="xs:string" use='required'/>
	<xs:attribute name='valid'      type="xs:boolean" use='required'/>
	<xs:attribute name='localIp'    type="xs:string" use='required'/>
	<xs:attribute name='localPort'  type="xs:nonNegativeInteger" use='required'/>
	<xs:attribute name='remoteIp'   type="xs:string" use='optional'/>
	<xs:attribute name='remotePort' type="xs:nonNegativeInteger" use='optional'/>
	<xs:attribute name='state'      type="xs:string" use='optional'/>
	<xs:attribute name='setting'    type="xs:string" use='required'/>
	<xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>

</xs:schema>
