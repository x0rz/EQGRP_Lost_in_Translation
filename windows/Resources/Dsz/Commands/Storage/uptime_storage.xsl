<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Uptime/Duration"/>
			<xsl:apply-templates select="Uptime/IdleTime"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Duration">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Uptime</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">days</xsl:attribute>
				<xsl:call-template name="StripLeadingZero">
					<xsl:with-param name="value">
						<xsl:value-of select="substring-before(substring-after(., 'P'), 'D')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">hours</xsl:attribute>
				<xsl:call-template name="StripLeadingZero">
					<xsl:with-param name="value">
						<xsl:value-of select="substring-before(substring-after(., 'T'), 'H')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">minutes</xsl:attribute>
				<xsl:call-template name="StripLeadingZero">
					<xsl:with-param name="value">
						<xsl:value-of select="substring-before(substring-after(., 'H'), 'M')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">seconds</xsl:attribute>
				<xsl:call-template name="StripLeadingZero">
					<xsl:with-param name="value">
						<xsl:value-of select="substring-before(substring-after(., 'M'), '.')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="IdleTime">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">IdleTime</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">days</xsl:attribute>
				<xsl:call-template name="StripLeadingZero">
					<xsl:with-param name="value">
						<xsl:value-of select="substring-before(substring-after(., 'P'), 'D')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">hours</xsl:attribute>
				<xsl:call-template name="StripLeadingZero">
					<xsl:with-param name="value">
						<xsl:value-of select="substring-before(substring-after(., 'T'), 'H')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">minutes</xsl:attribute>
				<xsl:call-template name="StripLeadingZero">
					<xsl:with-param name="value">
						<xsl:value-of select="substring-before(substring-after(., 'H'), 'M')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">seconds</xsl:attribute>
				<xsl:call-template name="StripLeadingZero">
					<xsl:with-param name="value">
						<xsl:value-of select="substring-before(substring-after(., 'M'), '.')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template name="StripLeadingZero">
		<xsl:param name="value"/>
		<xsl:choose>
			<xsl:when test="starts-with($value, '0')">
				<xsl:call-template name="StripLeadingZero">
					<xsl:with-param name="value" select="substring($value, 2)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:transform>