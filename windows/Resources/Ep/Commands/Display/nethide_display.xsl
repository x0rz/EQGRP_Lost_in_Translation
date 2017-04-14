<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

  <xsl:template match="Ports">
   <xsl:apply-templates select="Mode" />
   <xsl:apply-templates select="Port" /> 
   <xsl:apply-templates select="Success" />
  </xsl:template>

  <xsl:template match="Mode">
   <xsl:call-template name="PrintReturn"/>
   <xsl:text>Nethide running in </xsl:text>
   <xsl:choose>
     <xsl:when test="@mode = '0'">
	<xsl:text>USER_MODE</xsl:text>
     </xsl:when>
     <xsl:when test="@mode > '0'">
	<xsl:text>DRIVER_MODE</xsl:text>
     </xsl:when>
   </xsl:choose>
   <xsl:call-template name="PrintReturn"/>
  </xsl:template>

  <xsl:template match="Port">

  <xsl:choose>
   <xsl:when test="@index = '0'">
     <xsl:call-template name="PrintReturn"/>
     <xsl:text>Local Addresses			Remote Addresses</xsl:text>
     <xsl:call-template name="PrintReturn"/>
     <xsl:text>-----------------------------------------------------------------------</xsl:text>
     <xsl:call-template name="PrintReturn"/>
   </xsl:when>
  </xsl:choose>


   <xsl:text>[</xsl:text>  
   <xsl:value-of select="@index"/> 
   <xsl:text>] = </xsl:text>
   <xsl:value-of select="@lipAddr"/>
   <xsl:text>:</xsl:text>

   <xsl:choose>
    <xsl:when test="@lport = '0'">
     <xsl:text>any</xsl:text>
    </xsl:when>
    <xsl:when test="@lport = '65535'">
     <xsl:text>-----</xsl:text>
    </xsl:when>
    <xsl:when test="@lport > '0'">
      <xsl:value-of select="@lport"/>
    </xsl:when>
   </xsl:choose>

   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="16 - string-length(@lipAddr)"/>
   </xsl:call-template>

   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="5 - string-length(@lport)"/>
   </xsl:call-template>

   <xsl:text>	[</xsl:text>  
   <xsl:value-of select="@index"/> 
   <xsl:text>] = </xsl:text>
   <xsl:value-of select="@fipAddr"/>
   <xsl:text>:</xsl:text>

   <xsl:choose>
    <xsl:when test="@fport = '0'">
     <xsl:text>any</xsl:text>
    </xsl:when>
    <xsl:when test="@fport = '65535'">
     <xsl:text>-----</xsl:text>
    </xsl:when>
    <xsl:when test="@fport > '0'">
      <xsl:value-of select="@fport"/>
    </xsl:when>
   </xsl:choose>

   <xsl:call-template name="PrintReturn"/>
  </xsl:template>

  <xsl:template match="Success">
     <xsl:text>&#x09;</xsl:text>
     <xsl:text>The operation completed successfully</xsl:text> 
     <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:template>
  
  

</xsl:transform>

