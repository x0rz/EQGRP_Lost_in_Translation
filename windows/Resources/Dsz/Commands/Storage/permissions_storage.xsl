<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="ObjectPerms"/>
			<xsl:apply-templates select="Added"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="AclModified">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">AclModified</xsl:attribute>
			<xsl:element name="BoolValue">
					<xsl:attribute name="name">removePending</xsl:attribute>
					<xsl:value-of select="@removePending"/>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Mask</xsl:attribute>
				<xsl:apply-templates select="Mask"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ObjectPerms">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Object</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">owner</xsl:attribute>
				<xsl:value-of select="@accountName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ownerDomain</xsl:attribute>
				<xsl:value-of select="@accountDomainName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">group</xsl:attribute>
				<xsl:value-of select="@groupName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">groupDomain</xsl:attribute>
				<xsl:value-of select="@groupDomainName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">PermissionString</xsl:attribute>
				<xsl:value-of select="PermissionString"/>
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Flags</xsl:attribute>
				
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_DACL_AUTO_INHERIT_REQ"/>
					<xsl:with-param name="VarName" select="'SE_DACL_AUTO_INHERIT_REQ'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_DACL_AUTO_INHERITED"/>
					<xsl:with-param name="VarName" select="'SE_DACL_AUTO_INHERITED'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_DACL_DEFAULTED"/>
					<xsl:with-param name="VarName" select="'SE_DACL_DEFAULTED'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_DACL_PRESENT"/>
					<xsl:with-param name="VarName" select="'SE_DACL_PRESENT'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_DACL_PROTECTED"/>
					<xsl:with-param name="VarName" select="'SE_DACL_PROTECTED'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_GROUP_DEFAULTED"/>
					<xsl:with-param name="VarName" select="'SE_GROUP_DEFAULTED'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_OWNER_DEFAULTED"/>
					<xsl:with-param name="VarName" select="'SE_OWNER_DEFAULTED'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_RM_CONTROL_VALID"/>
					<xsl:with-param name="VarName" select="'SE_RM_CONTROL_VALID'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_SACL_AUTO_INHERIT_REQ"/>
					<xsl:with-param name="VarName" select="'SE_SACL_AUTO_INHERIT_REQ'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_SACL_AUTO_INHERITED"/>
					<xsl:with-param name="VarName" select="'SE_SACL_AUTO_INHERITED'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_SACL_DEFAULTED"/>
					<xsl:with-param name="VarName" select="'SE_SACL_DEFAULTED'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_SACL_PRESENT"/>
					<xsl:with-param name="VarName" select="'SE_SACL_PRESENT'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_SACL_PROTECTED"/>
					<xsl:with-param name="VarName" select="'SE_SACL_PROTECTED'"/>
				</xsl:call-template>
				<xsl:call-template name="SetBool">
					<xsl:with-param name="ElementName" select="Flags/SE_SELF_RELATIVE"/>
					<xsl:with-param name="VarName" select="'SE_SELF_RELATIVE'"/>
				</xsl:call-template>
			</xsl:element>
			
			<xsl:apply-templates select="Acl"/>
		</xsl:element>
	</xsl:template>
  
	<xsl:template match="Acl">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Acl</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			
			<xsl:apply-templates select="Ace"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Ace">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Ace</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">typeValue</xsl:attribute>
				<xsl:value-of select="@typeValue"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">domain</xsl:attribute>
				<xsl:value-of select="@domain"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">user</xsl:attribute>
				<xsl:value-of select="@user"/>
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Flags</xsl:attribute>
				<xsl:apply-templates select="Flags"/>
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Mask</xsl:attribute>
				<xsl:apply-templates select="Mask"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Flags">
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="ContainerInheritAce"/>
			<xsl:with-param name="VarName" select="'container_inherit_ace'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="InheritOnlyAce"/>
			<xsl:with-param name="VarName" select="'inherit_only_ace'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="InheritedAce"/>
			<xsl:with-param name="VarName" select="'inherited_ace'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="NoPropogateInheritAce"/>
			<xsl:with-param name="VarName" select="'no_propagate_inherit_ace'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="ObjectInheritAce"/>
			<xsl:with-param name="VarName" select="'object_inherit'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="FailedAccessAce"/>
			<xsl:with-param name="VarName" select="'failed_access_ace'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="SuccessfulAccessAce"/>
			<xsl:with-param name="VarName" select="'successful_access_ace'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="Mask">
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="Delete"/>
			<xsl:with-param name="VarName" select="'delete_mask'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="ExecuteMask"/>
			<xsl:with-param name="VarName" select="'execute_file_mask'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="FileAppendData"/>
			<xsl:with-param name="VarName" select="'file_append_data'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="FileDeleteChild"/>
			<xsl:with-param name="VarName" select="'file_delete_child'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="FileExecute"/>
			<xsl:with-param name="VarName" select="'file_execute'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="FileReadAttributes"/>
			<xsl:with-param name="VarName" select="'file_read_attr'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="FileReadData"/>
			<xsl:with-param name="VarName" select="'file_read_data'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="FileReadEA"/>
			<xsl:with-param name="VarName" select="'file_read_ea'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="FileWriteAttributes"/>
			<xsl:with-param name="VarName" select="'file_write_attr'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="FileWriteData"/>
			<xsl:with-param name="VarName" select="'file_write_data'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="FileWriteEA"/>
			<xsl:with-param name="VarName" select="'file_write_ea'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="FullControlMask"/>
			<xsl:with-param name="VarName" select="'full_control_mask'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="GenericReadMask"/>
			<xsl:with-param name="VarName" select="'generic_read_mask'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="GenericWriteMask"/>
			<xsl:with-param name="VarName" select="'generic_write_mask'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="ReadControl"/>
			<xsl:with-param name="VarName" select="'read_control'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="ReadWriteMask"/>
			<xsl:with-param name="VarName" select="'read_write_mask'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="Synchronize"/>
			<xsl:with-param name="VarName" select="'synchronize'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="WriteDac"/>
			<xsl:with-param name="VarName" select="'write_dac'"/>
		</xsl:call-template>
		<xsl:call-template name="SetBool">
			<xsl:with-param name="ElementName" select="WriteOwner"/>
			<xsl:with-param name="VarName" select="'write_owner'"/>
		</xsl:call-template>
  </xsl:template>

	<xsl:template name="SetBool">
		<xsl:param name="ElementName"/>
		<xsl:param name="VarName"/>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name"><xsl:value-of select="$VarName"/></xsl:attribute>
			
			<xsl:choose>
				<xsl:when test="$ElementName">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>	
    
</xsl:transform>