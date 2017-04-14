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
    <xs:choice minOccurs="0" maxOccurs="unbounded">
     <xs:element ref="Upgrade" />
     <xs:element ref="FileSize" />
     <xs:element ref="Error" />
     <xs:element ref="Autoload" minOccurs="0" maxOccurs="unbounded" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

  <xs:element name='Upgrade'>
    <xs:complexType>
	<xs:sequence>
	  <xs:element name='RemoteFile' type="xs:string" form="qualified"/>
	  <xs:element name='MatchFile'  type="xs:string" form="qualified"/>
	  <xs:element name='NewFile'    type="xs:string" form="qualified"/>
	  <xs:element name='OldFile'    type="xs:string" form="qualified"/>
	</xs:sequence>
	<xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>


 <xs:element name="FileSize">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:nonNegativeInteger">
     <xs:attribute name="lptimestamp" type="xs:dateTime" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>
</xs:schema>

