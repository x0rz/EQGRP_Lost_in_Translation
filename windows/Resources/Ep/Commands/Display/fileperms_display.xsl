<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="FilePerms">

  <xsl:text>&#x0D;&#x0A;AcctName </xsl:text>
  <xsl:value-of select="@accountName" />
  <xsl:text>&#x0D;&#x0A;DomainName </xsl:text>
  <xsl:value-of select="@domainName" />
  <xsl:text>&#x0D;&#x0A;GroupName </xsl:text>
  <xsl:value-of select="@groupName" />
  <xsl:text>&#x0D;&#x0A;GroupDomainName </xsl:text>
  <xsl:value-of select="@groupDomainName" />

  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:for-each select="Acl">
   <xsl:for-each select="Ace">
    <xsl:text>--------------------------------------------&#x0D;&#x0A;</xsl:text>
    <xsl:text>Type:   </xsl:text>
    <xsl:choose>
	<xsl:when test="@type = 0">
	    <xsl:text>ACCESS_ALLOWED_ACE_TYPE&#x0D;&#x0A;</xsl:text>
	</xsl:when>
	
	<xsl:when test="@type = 1">
	    <xsl:text>ACCESS_DENIED_ACE_TYPE&#x0D;&#x0A;</xsl:text>
	</xsl:when>
	<xsl:when test="@type = 2">
	    <xsl:text>SYSTEM_AUDIT_ACE_TYPE&#x0D;&#x0A;</xsl:text>
	</xsl:when>
	<xsl:when test="@type = 3">
	    <xsl:text>SYSTEM_ALARM_ACE_TYPE&#x0D;&#x0A;</xsl:text>
	</xsl:when>
	<xsl:when test="@type = 4">
	    <xsl:text>ACCESS_ALLOWED_COMPOUND_ACE_TYPE&#x0D;&#x0A;</xsl:text>
	</xsl:when>
	<xsl:when test="@type = 5">
	    <xsl:text>ACCESS_ALLOWED_OBJECT_ACE_TYPE&#x0D;&#x0A;</xsl:text>
	</xsl:when>
	<xsl:when test="@type = 6">
	    <xsl:text>ACCESS_DENIED_OBJECT_ACE_TYPE&#x0D;&#x0A;</xsl:text>
	</xsl:when>
	<xsl:when test="@type = 7">
	    <xsl:text>SYSTEM_AUDIT_OBJECT_ACE_TYPE&#x0D;&#x0A;</xsl:text>
	</xsl:when>
	<xsl:when test="@type = 8">
	    <xsl:text>SYSTEM_ALARM_OBJECT_ACE_TYPE&#x0D;&#x0A;</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:text>Unknown </xsl:text>
	    <xsl:value-of select="@type"/>
	    <xsl:text>&#x0D;&#x0A;</xsl:text>
        </xsl:otherwise>
    </xsl:choose>

    <xsl:text>User:   </xsl:text>
    <xsl:value-of select="@user" />
    <xsl:text>&#x0D;&#x0A;</xsl:text>

    <xsl:text>Domain: </xsl:text>
    <xsl:value-of select="@domain" />
    <xsl:text>&#x0D;&#x0A;</xsl:text>

    <xsl:apply-templates select="Mask"/>
    <xsl:apply-templates select="Flags"/>

   <xsl:text>&#x0D;&#x0A;</xsl:text>
   </xsl:for-each>
  </xsl:for-each>

 </xsl:template>

 <xsl:template match="Mask">
    <xsl:text>Access: </xsl:text>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
    <xsl:if test="FullControlMask">
     <xsl:text>        -Full Control.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="ReadWriteMask">
     <xsl:text>        -Read and write access.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="GenericWriteMask">
     <xsl:text>        -Write access.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="GenericReadMask">
     <xsl:text>        -Read access.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="Delete">
     <xsl:text>        -Delete access.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="WriteDac">
     <xsl:text>        -Write access to the discretionary ACL.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="WriteOwner">
     <xsl:text>        -Write owner.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="ExecuteMask">
     <xsl:text>        -Execute a file.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="FileExecute">
     <xsl:text>        -Execute a file or traverse a directory.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="FileReadData">
     <xsl:text>        -Read data from the file or list the contents of a directory.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="FileWriteData">
     <xsl:text>        -Write data to the file or create a file in the directory.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="FileWriteEA">
     <xsl:text>        -Write extended attributes.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="FileAppendData">
     <xsl:text>        -Append data to the file or create a subdirectory.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="FileDeleteChild">
     <xsl:text>        -Delete a directory and all the files it contains (its children),&#x0D;&#x0A;</xsl:text>
     <xsl:text>         even if the files are read-only.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="FileReadAttributes">
     <xsl:text>        -Read file attributes.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="FileWriteAttributes">
     <xsl:text>        -Change file attributes.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="ReadControl">
     <xsl:text>        -Read access to the security descriptor and owner.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="Synchronize">
     <xsl:text>        -Synchronize access.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="FileReadEA">
     <xsl:text>        -Read extended attributes.&#x0D;&#x0A;</xsl:text>
    </xsl:if>

   <xsl:if test="string-length(@unknown) > 0">
    <xsl:text>        Unknown Bits:</xsl:text>
    <xsl:value-of select="@unknown" />
    <xsl:text>&#x0D;&#x0A;</xsl:text>
   </xsl:if>
 </xsl:template>

 <xsl:template match="Flags">
    <xsl:text>Flags: </xsl:text>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
    <xsl:if test="FailedAccessAce">
     <xsl:text>        -Failed attempts to use the specified access rights cause the system to&#x0D;&#x0A;</xsl:text>
     <xsl:text>         generate an audit record in the security event log.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="SuccessfulAccessAce">
     <xsl:text>        -Successful uses of the specified access rights cause the system to&#x0D;&#x0A;</xsl:text>
     <xsl:text>         generate an audit record in the security event log.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="ContainerInheritAce">
     <xsl:text>        -The ACE is inherited by container objects.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="InheritOnlyAce">
     <xsl:text>        -The ACE does not apply to the object to which the ACL is assigned,&#x0D;&#x0A;</xsl:text>
     <xsl:text>         but it can be inherited by child objects. &#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="InheritedAce">
     <xsl:text>        -Inherited ACE.&#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="NoPropogateInheritAce">
     <xsl:text>        -The OBJECT_INHERIT_ACE and CONTAINER_INHERIT_ACE bits are not propagated&#x0D;&#x0A;</xsl:text>
     <xsl:text>         to an inherited ACE. &#x0D;&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="ObjectInheritAce">
     <xsl:text>        -The ACE is inherited by noncontainer objects.&#x0D;&#x0A;</xsl:text>
    </xsl:if>

    <xsl:if test="string-length(@unknown) > 0">
     <xsl:text>        Unknown Bits:</xsl:text>
     <xsl:value-of select="@unknown" />
     <xsl:text>&#x0D;&#x0A;</xsl:text>
    </xsl:if>
 </xsl:template>

</xsl:transform>