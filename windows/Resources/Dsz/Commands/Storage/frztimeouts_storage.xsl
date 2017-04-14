<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="TaskingInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">TaskingInfo</xsl:attribute>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">TaskType</xsl:attribute>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Value</xsl:attribute>
					<xsl:value-of select="TaskType"/>
				</xsl:element>
			</xsl:element>
			<xsl:if test="Address">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Address</xsl:attribute>
					<xsl:value-of select="Address"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="Mask">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Mask</xsl:attribute>
					<xsl:value-of select="Mask"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="CidrBits">
				<xsl:element name="IntValue">
					<xsl:attribute name="name">CidrBits</xsl:attribute>
					<xsl:value-of select="CidrBits"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="SendTimeout">
				<xsl:call-template name="TimeStorage">
					<xsl:with-param name="time" select="SendTimeout"/>
					<xsl:with-param name="name" select="'SendTimeout'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="RecvTimeout">
				<xsl:call-template name="TimeStorage">
					<xsl:with-param name="time" select="RecvTimeout"/>
					<xsl:with-param name="name" select="'RecvTimeout'"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="SendRetries">
				<xsl:element name="IntValue">
					<xsl:attribute name="name">SendRetries</xsl:attribute>
					<xsl:value-of select="SendRetries"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="RecvRetries">
				<xsl:element name="IntValue">
					<xsl:attribute name="name">RecvRetries</xsl:attribute>
					<xsl:value-of select="RecvRetries"/>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="FrzTimeouts">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Timeouts</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumTimeouts</xsl:attribute>
				<xsl:value-of select="@numTimeouts"/>
			</xsl:element>
			<xsl:apply-templates select="Timeout"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Timeout">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Timeout</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Address</xsl:attribute>
				<xsl:value-of select="@address"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Mask</xsl:attribute>
				<xsl:value-of select="@mask"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">CidrBits</xsl:attribute>
				<xsl:value-of select="@cidrBits"/>
			</xsl:element>
			<xsl:call-template name="TimeStorage">
				<xsl:with-param name="time" select="SendTimeout"/>
				<xsl:with-param name="name" select="'SendTimeout'"/>
			</xsl:call-template>
			<xsl:call-template name="TimeStorage">
				<xsl:with-param name="time" select="RecvTimeout"/>
				<xsl:with-param name="name" select="'RecvTimeout'"/>
			</xsl:call-template>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">SendRetries</xsl:attribute>
				<xsl:value-of select="@sendRetries"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">RecvRetries</xsl:attribute>
				<xsl:value-of select="@recvRetries"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>

