<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="ProcessInfo"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ProcessInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ProcessInfo</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="BasicInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">BasicInfo</xsl:attribute>
			<xsl:call-template name="TokenData">
				<xsl:with-param name="token" select="User"/>
				<xsl:with-param name="tokenName" select="'User'"/>
			</xsl:call-template>
			<xsl:call-template name="TokenData">
				<xsl:with-param name="token" select="Owner"/>
				<xsl:with-param name="tokenName" select="'Owner'"/>
			</xsl:call-template>
			<xsl:call-template name="TokenData">
				<xsl:with-param name="token" select="Group"/>
				<xsl:with-param name="tokenName" select="'PrimaryGroup'"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="TokenData">
		<xsl:param name="token"/>
		<xsl:param name="tokenName"/>
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name"><xsl:value-of select="$tokenName"/></xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="$token/@name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">attributes</xsl:attribute>
				<xsl:value-of select="$token/@attributes"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="$token/@type"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Groups">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Groups</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Privileges">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Privileges</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>

	<xsl:template match="Modules">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Modules</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Group">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Group</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			<xsl:call-template name="GroupAttributes"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="GroupAttributes">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">attributes</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">mask</xsl:attribute>
				<xsl:value-of select="@attributes"/>
			</xsl:element>
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="SE_GROUP_ENABLED" />
				<xsl:with-param name="var" select="'groupEnabled'" />
			</xsl:call-template>
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="SE_GROUP_ENABLED_BY_DEFAULT" />
				<xsl:with-param name="var" select="'groupEnabledByDefault'" />
			</xsl:call-template>
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="SE_GROUP_LOGON_ID" />
				<xsl:with-param name="var" select="'groupLogonId'" />
			</xsl:call-template>
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="SE_GROUP_MANDATORY" />
				<xsl:with-param name="var" select="'groupMandatory'" />
			</xsl:call-template>
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="SE_GROUP_OWNER" />
				<xsl:with-param name="var" select="'groupOwner'" />
			</xsl:call-template>
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="SE_GROUP_RESOURCE" />
				<xsl:with-param name="var" select="'groupResource'" />
			</xsl:call-template>
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="SE_GROUP_USE_FOR_DENY_ONLY" />
				<xsl:with-param name="var" select="'groupUseDeny'" />
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="PrivAttributes">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">attributes</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">mask</xsl:attribute>
				<xsl:value-of select="@attributes"/>
			</xsl:element>

			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="SE_PRIVILEGE_ENABLED" />
				<xsl:with-param name="var" select="'priv_enabled'" />
			</xsl:call-template>
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="SE_PRIVILEGE_ENABLED_BY_DEFAULT" />
				<xsl:with-param name="var" select="'priv_enabled_by_default'" />
			</xsl:call-template>
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="SE_PRIVILEGE_USED_FOR_ACCESS" />
				<xsl:with-param name="var" select="'priv_used_access'" />
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Privilege">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Privilege</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name" />
			</xsl:element>
			<xsl:call-template name="PrivAttributes"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Module">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Module</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">moduleName</xsl:attribute>
				<xsl:value-of select="@name" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">checksum</xsl:attribute>
				<xsl:value-of select="Checksum[@type='SHA1']" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">entryPoint</xsl:attribute>
				<xsl:value-of select="@entryPoint" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">imageSize</xsl:attribute>
				<xsl:value-of select="@imageSize" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">baseAddress</xsl:attribute>
				<xsl:value-of select="@baseAddress" />
			</xsl:element>
			<xsl:for-each select="Checksum">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Checksum</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Type</xsl:attribute>
						<xsl:value-of select="@type"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Value</xsl:attribute>
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
		
	<xsl:template name="Attributes">
		<xsl:param name="attr" />
		<xsl:param name="var" />
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var" />
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$attr">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

</xsl:transform>