<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="ScreenShot"/>
			<xsl:apply-templates select="WindowStations"/>
			<xsl:apply-templates select="Windows"/>
			<xsl:apply-templates select="Buttons"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Windows">
		<xsl:apply-templates select="Window"/>
	</xsl:template>
	<xsl:template match="Buttons">
		<xsl:apply-templates select="Button"/>
	</xsl:template>
	<xsl:template match="WindowStations">
		<xsl:apply-templates select="WindowStation"/>
	</xsl:template>
	
	<xsl:template match="ScreenShot">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Screenshot</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">path</xsl:attribute>
				<xsl:value-of select="@path"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">subdir</xsl:attribute>
				<xsl:value-of select="@subdir"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">filename</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="WindowStation">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">WindowStation</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:if test="@status">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Status</xsl:attribute>
					<xsl:value-of select="@status"/>
				</xsl:element>
			</xsl:if>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Visible</xsl:attribute>
				<xsl:choose>
					<xsl:when test="WindowStationFlag_Visible">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			
			<xsl:apply-templates select="Desktop"/>
		</xsl:element>
    </xsl:template>
    
    <xsl:template match="Desktop">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Desktop</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Window">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Window</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">hParent</xsl:attribute>
				<xsl:value-of select="@hParent"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">hWnd</xsl:attribute>
				<xsl:value-of select="@hWnd"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">pid</xsl:attribute>
				<xsl:value-of select="@pid"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">visible</xsl:attribute>
				<xsl:choose>
					<xsl:when test="WindowIsVisible">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">minimized</xsl:attribute>
				<xsl:choose>
					<xsl:when test="WindowIsMinimized">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">text</xsl:attribute>
				<xsl:value-of select="@title"/>
			</xsl:element>
		</xsl:element>
    </xsl:template>
    
    <xsl:template match="Button">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Button</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">text</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">enabled</xsl:attribute>
				<xsl:value-of select="@enabled"/>
			</xsl:element>
		</xsl:element>
    </xsl:template>
</xsl:transform>