<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/"> 
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Version"/>
			<xsl:apply-templates select="StatusInfo"/>
			<xsl:apply-templates select="AdaptersInfo"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="AdaptersInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">AdapterInfoItem</xsl:attribute>
			
  			<xsl:element name="BoolValue">
				<xsl:attribute name="name">ThreadRunning</xsl:attribute>
				<xsl:value-of select="@threadRunning"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">FilterActive</xsl:attribute>
				<xsl:value-of select="@filterActive"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumAdapters</xsl:attribute>
				<xsl:value-of select="@numAdapters"/>
			</xsl:element>
			
			<xsl:apply-templates select="Adapter"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Adapter"> 
		<xsl:element name="StringValue">
			<xsl:attribute name="name">AdapterName</xsl:attribute>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="StatusInfo"> 
		<xsl:apply-templates select="Status"/>
	</xsl:template>
	
	<xsl:template match="Status">
  		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">StatusItem</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Index</xsl:attribute>
				<xsl:value-of select="@index"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Process</xsl:attribute>
				<xsl:value-of select="BoundProcess"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Mailslot</xsl:attribute>
				<xsl:value-of select="Mailslot"/>
			</xsl:element>
			
			<xsl:call-template name="FileTimeFunction">
				<xsl:with-param name="time" select="LastTriggerTime"/>
				<xsl:with-param name="var"  select="'LastTriggerTime'"/>
			</xsl:call-template>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">LastTriggerStatusValue</xsl:attribute>
				<xsl:value-of select="LastTriggerStatus/@value"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">LastTriggerStatus</xsl:attribute>
				<xsl:value-of select="LastTriggerStatus"/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>

	<xsl:template match="Version">
  		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">VersionItem</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">major</xsl:attribute>
				<xsl:value-of select="Major"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">minor</xsl:attribute>
				<xsl:value-of select="Minor"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">fix</xsl:attribute>
				<xsl:value-of select="Fix"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="FileTimeFunction">
		<xsl:param name="time"/>
		<xsl:param name="var" />
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">time</xsl:attribute>
				<xsl:value-of select="$time"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="$time/@type"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>