<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

<xsl:template match="List">
  <xsl:apply-templates select="User" /> 
</xsl:template>


<xsl:template match="User">
  <xsl:value-of select="Username" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="@rid" />
  <xsl:text>:</xsl:text>

  <xsl:if test="not(Flags/IsHashException)">
   <xsl:value-of select="LanmanHash" />
   <xsl:text>:</xsl:text>
   <xsl:value-of select="NtHash" />
   <xsl:text>:</xsl:text>
  </xsl:if>

  <xsl:if test="Flags/IsHashException">
   <xsl:if test="Flags/IsRegNTcmp">
    <xsl:choose>
     <xsl:when test="Flags/IsRegLanmancmp">
       <xsl:value-of select="LanmanHash" />
       <xsl:text>:</xsl:text>
       <xsl:value-of select="NtHash" />
       <xsl:text>:</xsl:text>
     </xsl:when>
     <xsl:otherwise>
        <xsl:text>****** HASH NOT RETRIEVED ******:</xsl:text>
        <xsl:value-of select="NtHash" /> 
        <xsl:text>:</xsl:text>  
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>

   <xsl:if test="not(Flags/IsRegNTcmp)">
    <xsl:choose>
     <xsl:when test="not(Flags/IsRegLanmancmp)">
        <xsl:text>****** HASH NOT RETRIEVED ******:****** HASH NOT RETRIEVED ******:</xsl:text> 
     </xsl:when>
     <xsl:otherwise>
        <xsl:value-of select="LanmanHash" /> 
        <xsl:text>:</xsl:text> 
        <xsl:text>****** HASH NOT RETRIEVED ******:</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:if>
  </xsl:if>
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

</xsl:transform>


