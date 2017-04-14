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
     <xs:sequence>
       <xs:element ref="RawData" />
       <xs:element ref="Strings" />
       <xs:element ref="PerformanceInformation" />
     </xs:sequence>
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
    <xs:element ref="Error" minOccurs="0" maxOccurs="unbounded"/>
   </xs:sequence>
  </xs:complexType>
 </xs:element>

  <xs:element name='RawData' type="feStringElementWithTimestamp">
  </xs:element>
  <xs:element name='Strings'>
    <xs:complexType>
     <xs:sequence>
       <xs:element ref="String" minOccurs="0" maxOccurs="unbounded"/>
     </xs:sequence>
     <xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>
  <xs:element name='PerformanceInformation'>
    <xs:complexType>
     <xs:sequence>
       <xs:element ref="ObjectType" minOccurs="0" maxOccurs="unbounded"/>
     </xs:sequence>
     <xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
     <xs:attribute name='perfFreq' type='xs:nonNegativeInteger' use='required'/>
     <xs:attribute name='perfTime' type='xs:nonNegativeInteger' use='required'/>
     <xs:attribute name='perfTime100nSec' type='xs:nonNegativeInteger' use='required'/>
     <xs:attribute name='systemName' type='xs:string' use='required'/>
     <xs:attribute name='targetSet' type='xs:nonNegativeInteger' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name="String">
         <xs:complexType>
           <xs:simpleContent>
            <xs:extension base='xs:string'>
             <xs:attribute name='id' type='xs:nonNegativeInteger' use='required'/>
            </xs:extension>
           </xs:simpleContent>
         </xs:complexType>
  </xs:element>

  <xs:element name="ObjectType">
    <xs:complexType>
     <xs:sequence>
       <xs:element ref="Name" minOccurs="0"/>
       <xs:element ref="Help" minOccurs="0" />
       <xs:choice minOccurs="0">
        <xs:sequence>
          <xs:element ref="Counter" maxOccurs="unbounded"/>
        </xs:sequence>
        <xs:sequence>
          <xs:element name="Instance" maxOccurs="unbounded" form="qualified">
            <xs:complexType>
              <xs:sequence>
                <xs:element ref="Counter" minOccurs="0" maxOccurs="unbounded"/>
              </xs:sequence>
              <xs:attribute name="id" 			type="xs:integer" use="required"/>
              <xs:attribute name="name" 		type="xs:string" use="required"/>
              <xs:attribute name="parentInstance" 	type="xs:integer" use="required"/>
            </xs:complexType>
          </xs:element>
        </xs:sequence>
       </xs:choice>
     </xs:sequence>
     <xs:attribute name='objectHelpTitleIndex' type='xs:nonNegativeInteger' use='required'/>
     <xs:attribute name='objectNameTitleIndex' type='xs:nonNegativeInteger' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name='Name' type="xs:string"/>
  <xs:element name='Help' type="xs:string"/>

  <xs:element name="Counter">
    <xs:complexType>
     <xs:sequence>
       <xs:element ref="Name" minOccurs="0"/>
       <xs:element ref="Help" minOccurs="0"/>
       <xs:element ref="Value"/>
     </xs:sequence>
     <xs:attribute name='helpIndex' type='xs:nonNegativeInteger' use='required'/>
     <xs:attribute name='nameIndex' type='xs:nonNegativeInteger' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name="Value">
   <xs:complexType>
    <xs:simpleContent>
     <xs:extension base='feEmptyElement'>
      <xs:attribute name='suffix' type='xs:string' use='optional'/>
      <xs:attribute name='type'   type='xs:string' use='required'/>
      <xs:attribute name='value'  type='xs:string' use='required'/>
     </xs:extension>
    </xs:simpleContent>
   </xs:complexType>
  </xs:element>

  <xs:element name='Directory'>
    <xs:complexType>
	<xs:sequence>
	  <xs:element ref='File' minOccurs='0' maxOccurs='unbounded'/>
	</xs:sequence>

	<xs:attribute name='path' type='xs:string' use='required'/>
	<xs:attribute name='denied' type='xs:boolean' use='optional'/>
	<xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name='File'>
    <xs:complexType>
	<xs:sequence>
	  <xs:element ref='FileTime' minOccurs='3' maxOccurs='3'/>
	  <xs:choice minOccurs='0' maxOccurs='unbounded'>
	    <xs:element ref='FileAttributeDirectory'/>
	    <xs:element ref='FileAttributeArchive'/>
	    <xs:element ref='FileAttributeCompressed'/>
	    <xs:element ref='FileAttributeEncrypted'/>
	    <xs:element ref='FileAttributeHidden'/>
	    <xs:element ref='FileAttributeOffline'/>
	    <xs:element ref='FileAttributeReadonly'/>
	    <xs:element ref='FileAttributeSystem'/>
	    <xs:element ref='FileAttributeTemporary'/>
	  </xs:choice>
	</xs:sequence>

	<xs:attribute name='name' type='xs:string' use='required'/>
	<xs:attribute name='short' type='xs:string' use='required'/>
	<xs:attribute name='size' type='xs:unsignedLong' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name='FileAttributeDirectory'/>
  <xs:element name='FileAttributeArchive'/>
  <xs:element name='FileAttributeCompressed'/>
  <xs:element name='FileAttributeEncrypted'/>
  <xs:element name='FileAttributeHidden'/>
  <xs:element name='FileAttributeOffline'/>
  <xs:element name='FileAttributeReadonly'/>
  <xs:element name='FileAttributeSystem'/>
  <xs:element name='FileAttributeTemporary'/>

  <xs:element name='FileTime'>
    <xs:complexType>
	<xs:simpleContent>
	  <xs:extension base='xs:dateTime'>
	    <xs:attribute name='type' type='timeType' use='required'/>
	    <xs:attribute name='locale' type='localeType' use='required'/>
	  </xs:extension>
	</xs:simpleContent>
    </xs:complexType>
  </xs:element>

<!-- Types -->
 <xs:simpleType name='localeType'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value='remotelocal'/>
  </xs:restriction>
 </xs:simpleType>

 <xs:simpleType name='timeType'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value='modified'/>
    <xs:enumeration value='created'/>
    <xs:enumeration value='accessed'/>
  </xs:restriction>
 </xs:simpleType>

</xs:schema>


