<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="PingResponse">
		<xsl:apply-templates select="Response"/>
	</xsl:template>
	
	<xsl:template match="Response">
		<xsl:variable name="min_to_ms" select="number(substring-before(substring-after(Elapsed, 'H'), 'M'))*(60000)"/>
		<xsl:variable name="s_to_ms" select="number(substring-before(substring-after(Elapsed, 'M'), '.'))*(1000)"/>
		<xsl:variable name="ns_to_ms" select="number(substring(substring-after(Elapsed, '.'), 1, 3))"/>
		<xsl:variable name="ms" select="number($min_to_ms + $s_to_ms + $ns_to_ms)"/>
		
		<xsl:text>----------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Response (length=</xsl:text>
		<xsl:value-of select="@length"/>	  
		<xsl:text> elapsed=</xsl:text>
		<xsl:value-of select="$ms"/>
		<xsl:text> ms)</xsl:text>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>    </xsl:text>
		<xsl:value-of select="@type"/>
		<xsl:text> from </xsl:text>
		<xsl:choose>
			<xsl:when test="FromAddr/IPv6Address">
				<xsl:value-of select="FromAddr/IPv6Address"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="FromAddr/IPv4Address"/>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:text> -&gt; </xsl:text>
		<xsl:choose>
			<xsl:when test="ToAddr/IPv6Address">
				<xsl:value-of select="ToAddr/IPv6Address"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="ToAddr/IPv4Address"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:if test="@ttl">
			<xsl:text> -- TTL: </xsl:text>
			<xsl:value-of select="@ttl" />
		</xsl:if>
		
		<xsl:call-template name="PrintReturn" />
		
	</xsl:template>

</xsl:transform>