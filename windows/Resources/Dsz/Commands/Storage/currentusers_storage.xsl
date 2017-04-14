<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="CurrentUsers"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="CurrentUsers">
		<xsl:apply-templates select="User"/>
	</xsl:template>
	
	<xsl:template match="User">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">User</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">sessionId</xsl:attribute>
				<xsl:value-of select="@sessionId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">loginPid</xsl:attribute>
				<xsl:value-of select="@loginPid"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">host</xsl:attribute>
				<xsl:value-of select="@host"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">device</xsl:attribute>
				<xsl:value-of select="@device"/>
			</xsl:element>
			<xsl:if test="LoginTime/@type != 'invalid'">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">loginDate</xsl:attribute>
					<xsl:value-of select="substring-before(LoginTime, 'T')"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">loginTime</xsl:attribute>
					<xsl:value-of select="substring-before(substring-after(LoginTime, 'T'), '.')"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="IdleTime/@type != 'invalid'">
				<xsl:element name="IntValue">
					<xsl:attribute name="name">idleDays</xsl:attribute>
					<xsl:call-template name="StripLeadingZero">
						<xsl:with-param name="value">
							<xsl:value-of select="substring-before(substring-after(IdleTime, 'P'), 'D')"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">idleHours</xsl:attribute>
					<xsl:call-template name="StripLeadingZero">
						<xsl:with-param name="value">
							<xsl:value-of select="substring-before(substring-after(IdleTime, 'T'), 'H')"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">idleMinutes</xsl:attribute>
					<xsl:call-template name="StripLeadingZero">
						<xsl:with-param name="value">
							<xsl:value-of select="substring-before(substring-after(IdleTime, 'H'), 'M')"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">idleSeconds</xsl:attribute>
					<xsl:call-template name="StripLeadingZero">
						<xsl:with-param name="value">
							<xsl:value-of select="substring-before(substring-after(IdleTime, 'M'), '.')"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
			</xsl:if>
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