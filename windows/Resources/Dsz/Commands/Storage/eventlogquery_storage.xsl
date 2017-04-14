<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="eventlogquery_common.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Records" />
			<xsl:apply-templates select="EventLog" />
			<xsl:apply-templates select="ErrLog" />
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template match="EventLog">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">EventLog</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">numRecords</xsl:attribute>
				<xsl:value-of select="@numRecords" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">mostRecentRecordNum</xsl:attribute>
				<xsl:value-of select="@mostRecentRecordNum" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">oldestRecordNum</xsl:attribute>
				<xsl:value-of select="@oldestRecordNum" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">lastModifiedDate</xsl:attribute>
				<xsl:value-of select="substring-before(Time, 'T')" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">lastModifiedTime</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(Time, 'T'), '.')" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">error</xsl:attribute>
				<xsl:attribute name="value">0</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ErrLog">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ErrLog</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">lastModifiedDate</xsl:attribute>
				<xsl:attribute name="value">0001-01-01</xsl:attribute>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">lastModifiedTime</xsl:attribute>
				<xsl:attribute name="value">00:00:00</xsl:attribute>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">mostRecentRecordNum</xsl:attribute>
				<xsl:attribute name="value">0</xsl:attribute>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">numRecords</xsl:attribute>
				<xsl:attribute name="value">0</xsl:attribute>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">oldestRecordNum</xsl:attribute>
				<xsl:attribute name="value">0</xsl:attribute>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">error</xsl:attribute>
				<xsl:value-of select="@osError" />
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:transform>