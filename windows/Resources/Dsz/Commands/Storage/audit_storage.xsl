<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Status"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Status">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Status</xsl:attribute>			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">audit_mode</xsl:attribute>
				<xsl:choose>
					<xsl:when test="contains(@current, 'ON')">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">audit_status_avail</xsl:attribute>
				<xsl:text>true</xsl:text>
			</xsl:element>			
			<xsl:apply-templates select="Event"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Event">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Event</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">categoryGUID</xsl:attribute>
				<xsl:value-of select="@categoryGUID"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">subcategoryGUID</xsl:attribute>
				<xsl:value-of select="@subcategoryGUID"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">category</xsl:attribute>
				<xsl:value-of select="@category"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">categoryNative</xsl:attribute>
				<xsl:value-of select="@categoryNative"/>
			</xsl:element>
			<xsl:if test="@subcategory">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">subcategory</xsl:attribute>
					<xsl:value-of select="@subcategory"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="@subcategoryNative">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">subcategoryNative</xsl:attribute>
					<xsl:value-of select="@subcategoryNative"/>
				</xsl:element>
			</xsl:if>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">audit_event_success</xsl:attribute>
				<xsl:choose>
					<xsl:when test="OnSuccess">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">audit_event_failure</xsl:attribute>
				<xsl:choose>
					<xsl:when test="OnFailure">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:transform>