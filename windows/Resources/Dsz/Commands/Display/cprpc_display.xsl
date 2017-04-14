<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransformsNoUnknown.xsl"/>
	
	<xsl:template match="RpcId">
		<xsl:text>RPC started as id </xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="RpcResult">
		<xsl:text>RPC completed:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>  Address : </xsl:text>
		<xsl:value-of select="@address"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>   Status : </xsl:text>
		<xsl:value-of select="@result"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="@resultStr"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>       Id : </xsl:text>
		<xsl:value-of select="@rpcId"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>     Data : </xsl:text>
		<xsl:value-of select="OutputData/@length"/>
		<xsl:text> bytes</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>
