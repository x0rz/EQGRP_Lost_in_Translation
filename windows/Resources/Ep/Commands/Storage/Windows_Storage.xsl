<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="StandardTransforms.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="no"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="WindowStation"/>
			<xsl:apply-templates select="Window"/>
			<xsl:apply-templates select="Button"/>
			<xsl:apply-templates select="ScreenShot"/>
	    </xsl:element>
	</xsl:template>

	<xsl:template match="WindowStation">
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">WindowStation</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@name"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">bool</xsl:attribute>
			<xsl:attribute name="name">visible</xsl:attribute>
			<xsl:choose>
			<xsl:when test="WindowStationFlag_Visible">
				<xsl:attribute name="value">true</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="value">false</xsl:attribute>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name"><xsl:value-of select="concat(@name, '_numDesktops')"/></xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="count(Desktop)"/></xsl:attribute>
		</xsl:element>
		
		<xsl:apply-templates select="Desktop"/>
    </xsl:template>
    
    <xsl:template match="Desktop">
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name"><xsl:value-of select="concat(../@name, '_desktop')"/></xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Window">
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">hParent</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@hParent"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">hWnd</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@hWnd"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">int</xsl:attribute>
			<xsl:attribute name="name">pid</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@pid"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">bool</xsl:attribute>
			<xsl:attribute name="name">visible</xsl:attribute>
			<xsl:choose>
			<xsl:when test="WindowIsVisible">
				<xsl:attribute name="value">true</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="value">false</xsl:attribute>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">bool</xsl:attribute>
			<xsl:attribute name="name">minimized</xsl:attribute>
			<xsl:choose>
			<xsl:when test="WindowIsMinimized">
				<xsl:attribute name="value">true</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="value">false</xsl:attribute>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">text</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@title"/></xsl:attribute>
		</xsl:element>
    </xsl:template>
    
    <xsl:template match="Button">
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">text</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">int</xsl:attribute>
			<xsl:attribute name="name">id</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@id"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">bool</xsl:attribute>
			<xsl:attribute name="name">enabled</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@enabled"/></xsl:attribute>
		</xsl:element>
    </xsl:template>
    
    <xsl:template match="ScreenShot">
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">file</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="concat('ScreenShots/', .)"/></xsl:attribute>
		</xsl:element>
    </xsl:template>
</xsl:transform>