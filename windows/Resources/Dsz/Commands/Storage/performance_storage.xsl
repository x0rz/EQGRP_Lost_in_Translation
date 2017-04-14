<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="PerformanceHeader"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="PerformanceHeader">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Performance</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SystemName</xsl:attribute>
				<xsl:value-of select="@systemName"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">PerfCount</xsl:attribute>
				<xsl:value-of select="@perfCount"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">PerfCountsPerSecond</xsl:attribute>
				<xsl:value-of select="@perfCountsPerSecond"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<!-- This is deprecated -->
				<xsl:attribute name="name">PerfCountPerSecond</xsl:attribute>
				<xsl:value-of select="@perfCountsPerSecond"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">PerfTime100nSec</xsl:attribute>
				<xsl:value-of select="@perfTime100nSec"/>
			</xsl:element>
			
			<xsl:apply-templates select="ObjectHeader"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ObjectHeader">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Object</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">HelpIndex</xsl:attribute>
				<xsl:value-of select="@helpIndex"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NameIndex</xsl:attribute>
				<xsl:value-of select="@nameIndex"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Help</xsl:attribute>
				<xsl:value-of select="Help"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			
			<xsl:apply-templates select="Instance"/>
			<xsl:apply-templates select="Counter"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Instance">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Instance</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Parent</xsl:attribute>
				<xsl:value-of select="@parent"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			
			<xsl:apply-templates select="Counter"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Counter">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Counter</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">HelpIndex</xsl:attribute>
				<xsl:value-of select="@helpIndex"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NameIndex</xsl:attribute>
				<xsl:value-of select="@nameIndex"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Help</xsl:attribute>
				<xsl:value-of select="Help"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="Value"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ValueType</xsl:attribute>
				<xsl:value-of select="Value/@type"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ValueSuffix</xsl:attribute>
				<xsl:value-of select="Value/@suffix"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>