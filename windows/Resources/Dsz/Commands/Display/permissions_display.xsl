<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
<xsl:template match="AclModified">
	<xsl:text>Success: Permissions modified</xsl:text>
	<xsl:call-template name="PrintReturn"/>
	<xsl:if test="contains(@removePending, 'true')">
		<xsl:text>Permission modifications will be reverted when the command is stopped</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:apply-templates select="Mask"/>
</xsl:template>

<xsl:template match="ObjectPerms">

	<xsl:call-template name="PrintReturn"/>
	
	<xsl:call-template name="Whitespace">
		<xsl:with-param name="i" select="11 - string-length(@type)"/>
	</xsl:call-template>
	<xsl:value-of select="@type"/>
	<xsl:text> : </xsl:text>
	<xsl:value-of select="@name"/>
	<xsl:call-template name="PrintReturn"/>
	
	<xsl:text>    Account : </xsl:text>
	<xsl:value-of select="@accountDomainName"/>
	<xsl:text>\</xsl:text>
	<xsl:value-of select="@accountName"/>
	<xsl:call-template name="PrintReturn"/>
	
	<xsl:text>      Group : </xsl:text>
	<xsl:value-of select="@groupDomainName"/>
	<xsl:text>\</xsl:text>
	<xsl:value-of select="@groupName"/>
	<xsl:call-template name="PrintReturn"/>

	<xsl:text>      Flags : </xsl:text>
	<xsl:call-template name="PrintReturn"/>
	<xsl:for-each select="Flags/node()">
		<xsl:if test="string-length(name(.)) &gt; 0">
			<xsl:text>          </xsl:text>
			<xsl:value-of select="name(.)"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>		
	</xsl:for-each>

	<!--
	<xsl:text>Perm String : </xsl:text>
	<xsl:call-template name="PrintReturn"/>
	<xsl:text>          </xsl:text>
	<xsl:value-of select="PermissionString"/>
	<xsl:call-template name="PrintReturn"/>
	-->

	<xsl:call-template name="PrintReturn"/>
	<xsl:apply-templates select="Acl"/>
</xsl:template>

<xsl:template match="Acl">
	
	<xsl:text>--------------------------------------------</xsl:text>
    <xsl:call-template name="PrintReturn"/>
	<xsl:value-of select="@type"/>
	<xsl:call-template name="PrintReturn"/>
	
	<xsl:text>  Type : </xsl:text>
	<xsl:value-of select="Ace/@type"/>
	<xsl:call-template name="PrintReturn"/>
	
	<xsl:text>  User : </xsl:text>
	<xsl:value-of select="Ace/@user"/>
	<xsl:call-template name="PrintReturn"/>

	<xsl:text>Domain : </xsl:text>
	<xsl:value-of select="Ace/@domain" />
	<xsl:call-template name="PrintReturn"/>

	<xsl:apply-templates select="Ace/Mask"/>
	<xsl:apply-templates select="Ace/Flags"/>
	<xsl:call-template name="PrintReturn"/>
</xsl:template>

<xsl:template match="Mask">
	<xsl:text>Access: </xsl:text>
	<xsl:call-template name="PrintReturn"/>
	<xsl:if test="FullControlMask">
		<xsl:text>        -Full Control</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="ReadWriteMask">
		<xsl:text>        -Read and write access</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="GenericWriteMask">
		<xsl:text>        -Write access</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="GenericReadMask">
		<xsl:text>        -Read access</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="Delete">
		<xsl:text>        -Delete access</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="WriteDac">
		<xsl:text>        -Write access to the discretionary ACL</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="WriteOwner">
		<xsl:text>        -Write owner</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="ExecuteMask">
		<xsl:text>        -Execute a file</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="FileExecute">
		<xsl:text>        -Execute a file or traverse a directory</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="FileReadData">
		<xsl:text>        -Read data from the file or list the contents of a directory</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="FileWriteData">
		<xsl:text>        -Write data to the file or create a file in the directory</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="FileWriteEA">
		<xsl:text>        -Write extended attributes</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="FileAppendData">
		<xsl:text>        -Append data to the file or create a subdirectory</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="FileDeleteChild">
		<xsl:text>        -Delete a directory and all the files it contains (its children),</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>         even if the files are read-only</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="FileReadAttributes">
		<xsl:text>        -Read file attributes</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="FileWriteAttributes">
		<xsl:text>        -Change file attributes</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="ReadControl">
		<xsl:text>        -Read access to the security descriptor and owner</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="Synchronize">
		<xsl:text>        -Synchronize access</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="FileReadEA">
		<xsl:text>        -Read extended attributes</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>

	<xsl:if test="string-length(@unknown) > 0">
		<xsl:text>        Unknown Bits:</xsl:text>
		<xsl:value-of select="@unknown" />
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
</xsl:template>

<xsl:template match="Flags">
	<xsl:text>Flags: </xsl:text>
	<xsl:call-template name="PrintReturn"/>
	
	<xsl:if test="FailedAccessAce">
		<xsl:text>        -Failed attempts to use the specified access rights cause the system to</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>         generate an audit record in the security event log</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="SuccessfulAccessAce">
		<xsl:text>        -Successful uses of the specified access rights cause the system to</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>         generate an audit record in the security event log</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="ContainerInheritAce">
		<xsl:text>        -The ACE is inherited by container objects</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="InheritOnlyAce">
		<xsl:text>        -The ACE does not apply to the object to which the ACL is assigned,</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>         but it can be inherited by child objects</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="InheritedAce">
		<xsl:text>        -Inherited ACE</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="NoPropogateInheritAce">
		<xsl:text>        -The OBJECT_INHERIT_ACE and CONTAINER_INHERIT_ACE bits are not propagated</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>         to an inherited ACE</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
	<xsl:if test="ObjectInheritAce">
		<xsl:text>        -The ACE is inherited by noncontainer objects</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>

	<xsl:if test="string-length(@unknown) > 0">
		<xsl:text>        Unknown Bits:</xsl:text>
		<xsl:value-of select="@unknown" />
		<xsl:call-template name="PrintReturn"/>
	</xsl:if>
</xsl:template>

</xsl:transform>
