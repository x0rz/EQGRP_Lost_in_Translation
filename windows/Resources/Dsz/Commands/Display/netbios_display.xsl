<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="NetBios">
  		<xsl:text>---------------------------------------------------------------------</xsl:text>
  		<xsl:call-template name="PrintReturn" />
  		<xsl:apply-templates select="Adapter" />
  		<xsl:call-template name="PrintReturn" />
	</xsl:template>

 	<xsl:template match="Adapter">
		<xsl:apply-templates select="Names"/>
  		<xsl:call-template name="PrintReturn" />
  		<xsl:text>Adapter Address: </xsl:text>
  		<xsl:value-of select="@adapter_addr" />
  		<xsl:call-template name="PrintReturn" />
  		<xsl:text>Adapter Type   : </xsl:text>
		<xsl:choose>
 			<xsl:when test='@adapter_type="0xfe"'>
				<xsl:text>Ethernet Adapter</xsl:text>
			</xsl:when>
			<xsl:when test='@adapter="0xff"'>
				<xsl:text>Token Ring</xsl:text>
			</xsl:when>
		</xsl:choose>

  		<xsl:call-template name="PrintReturn" />
	</xsl:template>

	<xsl:template match="Names">
   		<xsl:value-of select="Name" />
		<xsl:call-template name="Whitespace">
    			<xsl:with-param name="i" select="5" />
   		</xsl:call-template>
   		<xsl:value-of select="NetName" />
   		<xsl:call-template name="Whitespace">
    			<xsl:with-param name="i" select="25 - string-length(NetName)" />
   		</xsl:call-template>
   		<xsl:value-of select="Type" />
  		<xsl:call-template name="PrintReturn" />
	</xsl:template>

</xsl:transform>