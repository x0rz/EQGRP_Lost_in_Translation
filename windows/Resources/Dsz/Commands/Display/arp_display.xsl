<?xml version='1.1' ?>
<xsl:transform 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:common="urn:cp:ea22a511-6ea9-9740-a1375558196f4b4b/common"
	version="1.0">
	<xsl:import href="include/StandardTransforms.xsl" />
	<xsl:import href="include/Math.xsl"/>
	
	<xsl:template match="ArpEntries">
		<xsl:apply-templates select="ArpHeader"/>
		<xsl:apply-templates select="ArpEntry"/>
	</xsl:template>
	
	<xsl:template match="ArpHeader">
		<xsl:call-template name="PrintReturn" />
		<xsl:text>       Internet Address         State/Type     Physical Address      Interface</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>-----------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="ArpEntry">
		<xsl:choose>
			<xsl:when test="IP/IPv6Address">
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="30 - string-length(IP/IPv6Address)" />
				</xsl:call-template>
				<xsl:value-of select="IP/IPv6Address" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="30 - string-length(IP/IPv4Address)" />
				</xsl:call-template>
				<xsl:value-of select="IP/IPv4Address" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="2" />
		</xsl:call-template>

		<xsl:choose>
			<xsl:when test="@state">
				<xsl:value-of select="@state" />
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="13 - string-length(@state)" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@type" />
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="13 - string-length(@type)" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:choose>
			<xsl:when test="starts-with(Physical/MacAddress, '01-00-00-00-00-00-00-00-')">
				<!-- the bits after this pattern should be printed as an IPv4 address -->
				<xsl:variable name="ip" select="substring-after(Physical/MacAddress, '01-00-00-00-00-00-00-00-')"/>
				<xsl:variable name="first" select="substring-before($ip, '-')"/>
				<xsl:variable name="ip2" select="substring-after(substring-after($ip, $first), '-')"/>
				<xsl:variable name="second" select="substring-before($ip2, '-')"/>
				<xsl:variable name="ip3" select="substring-after(substring-after($ip2, $second), '-')"/>
				<xsl:variable name="third" select="substring-before($ip3, '-')"/>
				<xsl:variable name="fourth" select="substring-after(substring-after($ip3, $third), '-')"/>
				<xsl:call-template name="convert-to-base-10">
					<xsl:with-param name="number" select="$first"/>
					<xsl:with-param name="from-base" select="'16'"/>
				</xsl:call-template>
				<xsl:text>.</xsl:text>
				<xsl:call-template name="convert-to-base-10">
					<xsl:with-param name="number" select="$second"/>
					<xsl:with-param name="from-base" select="'16'"/>
				</xsl:call-template>
				<xsl:text>.</xsl:text>
				<xsl:call-template name="convert-to-base-10">
					<xsl:with-param name="number" select="$third"/>
					<xsl:with-param name="from-base" select="'16'"/>
				</xsl:call-template>
				<xsl:text>.</xsl:text>
				<xsl:call-template name="convert-to-base-10">
					<xsl:with-param name="number" select="$fourth"/>
					<xsl:with-param name="from-base" select="'16'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="Physical/MacAddress" />
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="20 - string-length(Physical/MacAddress)" />
				</xsl:call-template>		
			</xsl:otherwise>
		</xsl:choose>

		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="2" />
		</xsl:call-template>
			
		<xsl:value-of select="@adapter" />

		<xsl:if test="FlagIsRouter or FlagIsUnreachable">
			<xsl:text> (</xsl:text>
			<xsl:if test="FlagIsRouter">
				<xsl:text> ROUTER </xsl:text>
			</xsl:if>
			<xsl:if test="FlagIsUnreachable">
				<xsl:text> UNREACHABLE </xsl:text>
			</xsl:if>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>

</xsl:transform>
