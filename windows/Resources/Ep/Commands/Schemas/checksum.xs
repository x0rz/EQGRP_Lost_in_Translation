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
     <xs:element ref="Directory" />
     <xs:element ref="MaxEntries" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice minOccurs="0">
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

  <xs:element name='Directory'>
    <xs:complexType>
	<xs:sequence>
	  <xs:element ref='File' minOccurs='0' maxOccurs='unbounded'/>
	</xs:sequence>

	<xs:attribute name='path' type='xs:string' use='required'/>
	<xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name='File'>
    <xs:complexType>
	<xs:attribute name='name'     type='xs:string' use='required'/>
	<xs:attribute name='checksum' type='xs:string' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name='MaxEntries' type="feEmptyElementWithTimestamp"/>

</xs:schema>
