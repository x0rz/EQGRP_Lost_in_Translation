<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Device">
   <xsl:text>&#x0D;&#x0A;</xsl:text>
   <xsl:text>______________________________________________________________</xsl:text>
   <xsl:text>&#x0D;&#x0A;</xsl:text>
   <xsl:value-of select="@index"/>
   <xsl:text>:&#x0D;&#x0A;</xsl:text>

   <xsl:text>&#x09;DeviceDesc:       </xsl:text>
   <xsl:value-of select="DeviceDesc" />
   <xsl:text>&#x0D;&#x0A;</xsl:text>

   <xsl:text>&#x09;Driver:           </xsl:text>
   <xsl:value-of select="Driver" />
   <xsl:text>&#x0D;&#x0A;</xsl:text>

   <xsl:text>&#x09;FriendlyName:     </xsl:text>
   <xsl:value-of select="FriendlyName" />
   <xsl:text>&#x0D;&#x0A;</xsl:text>

   <xsl:text>&#x09;HwdID(1st string):</xsl:text>
   <xsl:value-of select="HardwareID" />
   <xsl:text>&#x0D;&#x0A;</xsl:text>

   <xsl:text>&#x09;LocationInfo:     </xsl:text>
   <xsl:value-of select="LocationInfo" />
   <xsl:text>&#x0D;&#x0A;</xsl:text>

   <xsl:text>&#x09;Mfg:              </xsl:text>
   <xsl:value-of select="Mfg" />
   <xsl:text>&#x0D;&#x0A;</xsl:text>

   <xsl:text>&#x09;PhysDevObjName:   </xsl:text>
   <xsl:value-of select="PhysDevObjName" />
   <xsl:text>&#x0D;&#x0A;</xsl:text>

   <xsl:text>&#x09;ServPth:          </xsl:text>
   <xsl:value-of select="ServicePath" />
   <xsl:text>&#x0D;&#x0A;</xsl:text>


   <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:template>


</xsl:transform>