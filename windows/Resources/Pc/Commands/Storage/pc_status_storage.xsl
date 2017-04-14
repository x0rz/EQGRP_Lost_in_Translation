<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="PcStatus"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="PcStatus">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">PcStatus</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Major</xsl:attribute>
				<xsl:value-of select="@versionMajor"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Minor</xsl:attribute>
				<xsl:value-of select="@versionMinor"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Build</xsl:attribute>
				<xsl:value-of select="@versionBuild"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="@pcId"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Trigger</xsl:attribute>

				<xsl:element name="IntValue">
					<xsl:attribute name="name">NumReceived</xsl:attribute>
					<xsl:value-of select="Trigger/@numReceived"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Status</xsl:attribute>
					<xsl:value-of select="Trigger/@status"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Type</xsl:attribute>
					<xsl:value-of select="Trigger/@type"/>
				</xsl:element>
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">LastReceived</xsl:attribute>

					<xsl:element name="StringValue">
						<xsl:attribute name="name">Date</xsl:attribute>
						<xsl:value-of select="substring-before(Trigger/LastReceived, 'T')"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Time</xsl:attribute>
						<xsl:value-of select="substring-before(substring-after(Trigger/LastReceived, 'T'), '.')"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Type</xsl:attribute>
						<xsl:value-of select="Trigger/LastReceived/@type"/>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>