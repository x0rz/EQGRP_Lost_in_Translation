<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Disabled"/>
			<xsl:apply-templates select="Status"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Enabled">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">enabled</xsl:attribute>
			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">closePending</xsl:attribute>
				<xsl:value-of select="@closePending"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">port</xsl:attribute>
				<xsl:value-of select="@port"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">protocol</xsl:attribute>
				<xsl:value-of select="@protocol"/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Delete">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">delete</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">port</xsl:attribute>
				<xsl:value-of select="@port"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">protocol</xsl:attribute>
				<xsl:value-of select="@protocol"/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Status">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">status</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">modify</xsl:attribute>
				<xsl:value-of select="@modify"/>
			</xsl:element>
			<xsl:if test="Standard">
				<xsl:call-template name="FirewallStorage">
					<xsl:with-param name='Name' select="'Local'" />
					<xsl:with-param name='Value' select="Standard"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="Domain">
				<xsl:call-template name="FirewallStorage">
					<xsl:with-param name='Name' select="'Domain'" />
					<xsl:with-param name='Value' select="Domain"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="Private">
				<xsl:call-template name="FirewallStorage">
					<xsl:with-param name='Name' select="'Private'" />
					<xsl:with-param name='Value' select="Private"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="Public">
				<xsl:call-template name="FirewallStorage">
					<xsl:with-param name='Name' select="'Public'" />
					<xsl:with-param name='Value' select="Public"/>
				</xsl:call-template>
			</xsl:if>			
			<xsl:if test="Local">
				<xsl:call-template name="FirewallStorage">
					<xsl:with-param name='Name' select="'Local'" />
					<xsl:with-param name='Value' select="Local"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="FirewallStorage">
		<xsl:param name="Name"/>
		<xsl:param name="Value" />
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name"><xsl:value-of select="$Name"/></xsl:attribute>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">enabled</xsl:attribute>
				<xsl:value-of select="$Value/@enabled"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">allowExceptions</xsl:attribute>
				<xsl:value-of select="$Value/@exceptions"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">active</xsl:attribute>
				<xsl:value-of select="$Value/@active"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">inbound</xsl:attribute>
				<xsl:value-of select="$Value/@inbound"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">outbound</xsl:attribute>
				<xsl:value-of select="$Value/@outbound"/>
			</xsl:element>
			
			<xsl:for-each select="$Value/Application">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Application</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">ProgramPath</xsl:attribute>
						<xsl:value-of select="Program"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">ProgramName</xsl:attribute>
						<xsl:value-of select="ProgramName"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Scope</xsl:attribute>
						<xsl:value-of select="Scope"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Status</xsl:attribute>
						<xsl:value-of select="Status"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Rule</xsl:attribute>
						<xsl:value-of select="RuleString"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Direction</xsl:attribute>
						<xsl:value-of select="Direction"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Action</xsl:attribute>
						<xsl:value-of select="Action"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Group</xsl:attribute>
						<xsl:value-of select="Group"/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
			<xsl:for-each select="$Value/Port">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Port</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Port</xsl:attribute>
						<xsl:value-of select="Port"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Protocol</xsl:attribute>
						<xsl:value-of select="Protocol"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Scope</xsl:attribute>
						<xsl:value-of select="Scope"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Status</xsl:attribute>
						<xsl:value-of select="Status"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">PortName</xsl:attribute>
						<xsl:value-of select="PortName"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Rule</xsl:attribute>
						<xsl:value-of select="RuleString"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Direction</xsl:attribute>
						<xsl:value-of select="Direction"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Action</xsl:attribute>
						<xsl:value-of select="Action"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Group</xsl:attribute>
						<xsl:value-of select="Group"/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
</xsl:transform>