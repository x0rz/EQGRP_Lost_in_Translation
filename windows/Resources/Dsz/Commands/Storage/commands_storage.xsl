<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="LocalCommand">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Command</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="Id"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">TaskId</xsl:attribute>
				<xsl:value-of select="TaskId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ParentId</xsl:attribute>
				<xsl:value-of select="ParentId"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">FullCommand</xsl:attribute>
				<xsl:value-of select="FullCommand"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">CommandAsTyped</xsl:attribute>
				<xsl:value-of select="CommandAsTyped"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">TargetAddress</xsl:attribute>
				<xsl:value-of select="TargetAddress"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">BytesSent</xsl:attribute>
				<xsl:value-of select="BytesSent"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">BytesReceived</xsl:attribute>
				<xsl:value-of select="BytesReceived"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Status</xsl:attribute>
				<xsl:value-of select="Status"/>
			</xsl:element>
			
			<xsl:apply-templates select="Rpc"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="RemoteCommand">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Command</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="Id"/>
			</xsl:element>
			
			<xsl:if test="Name">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Name</xsl:attribute>
					<xsl:value-of select="Name"/>
				</xsl:element>
			</xsl:if>
			
			<xsl:apply-templates select="Thread"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Rpc">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Rpc</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Thread">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Thread</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">CmdId</xsl:attribute>
				<xsl:value-of select="@cmdId"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">TaskId</xsl:attribute>
				<xsl:value-of select="@taskId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">RpcId</xsl:attribute>
				<xsl:value-of select="@rpcId"/>
			</xsl:element>
			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Exception</xsl:attribute>
				<xsl:value-of select="@exception"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Interface</xsl:attribute>
				<xsl:value-of select="@interface"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Provider</xsl:attribute>
				<xsl:value-of select="@provider"/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
	
</xsl:transform>