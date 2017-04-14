<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="ClearedProcess">
   <xsl:text>Cleared process</xsl:text>
   <xsl:call-template name="PrintReturn"/>

   <xsl:text>      Old ID : </xsl:text>
   <xsl:value-of select="@id"/>
   <xsl:call-template name="PrintReturn"/>

   <xsl:text>Old EProcess : </xsl:text>
   <xsl:value-of select="@eprocess"/>
   <xsl:call-template name="PrintReturn"/>

 </xsl:template>

</xsl:transform>