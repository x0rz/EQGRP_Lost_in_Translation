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
     <xs:element ref="MachineInfo" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="MachineInfo">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Name"    type="xs:string" form="qualified" />
    <xs:element name="Comment" type="xs:string" form="qualified" />
    <xs:element name="Type"                     form="qualified"  >
     <xs:complexType>
      <xs:sequence>
       <xs:element name="FlagsList" form="qualified">
        <xs:complexType>
         <xs:sequence>
          <xs:element minOccurs="0" form="qualified" name="SvTypeWorkstation" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeServer"      />
          <xs:element minOccurs="0" form="qualified" name="SvTypeSqlServer" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeDomainCtrl" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeDomainBakCtrl" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeTimeSource" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeAfp" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeNovell" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeDomainMember" />
          <xs:element minOccurs="0" form="qualified" name="SvTypePrintQServer" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeDialinServer" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeXenixServer" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeServerUnix" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeNT" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeWFW" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeServerMfpn" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeServerNT" />
          <xs:element minOccurs="0" form="qualified" name="SvTypePotentialBrowser" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeBackupBrowser" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeMasterBrowser" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeDomainMaster" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeServerOsf" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeServerVms" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeWindows" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeDFS" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeClusterNT" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeTerminalServer" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeClusterVsNT" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeDCE" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeAlternateXport" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeLocalListOnly" />
          <xs:element minOccurs="0" form="qualified" name="SvTypeDomainEnum" />
         </xs:sequence>
        </xs:complexType>
       </xs:element>
      </xs:sequence>
      <xs:attribute name="mask"    type="xs:string" />
      <xs:attribute name="unknown" type="xs:string" />
     </xs:complexType>
    </xs:element>
   </xs:sequence>
   <xs:attribute name='major'  type='xs:nonNegativeInteger'         use='required'/>
   <xs:attribute name='minor'  type='xs:nonNegativeInteger'         use='required'/>
   <xs:attribute name='platformId' type='xs:nonNegativeInteger'     use='required'/>
   <xs:attribute name='lptimestamp'    type='xs:dateTime'           use='required'/>
  </xs:complexType>
 </xs:element>

</xs:schema>
