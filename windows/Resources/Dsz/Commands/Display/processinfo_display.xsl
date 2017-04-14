<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="include/StandardTransforms.xsl" />
	<xsl:output method="text" />
	
	<xsl:template match="ProcessInfo">
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="3" />
		</xsl:call-template>
		<xsl:text>Process ID : </xsl:text>
		<xsl:value-of select="@id" />
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="BasicInfo"/>
		<xsl:apply-templates select="Groups"/>
		<xsl:apply-templates select="Privileges"/>
		<xsl:apply-templates select="Modules"/>
	</xsl:template>
	
	<xsl:template match="BasicInfo">
		<xsl:call-template name="PrintTokenInfo">
			<xsl:with-param name="token" select="User"/>
			<xsl:with-param name="tokenName" select="'User'"/>
		</xsl:call-template>
		<xsl:call-template name="PrintTokenInfo">
			<xsl:with-param name="token" select="Owner"/>
			<xsl:with-param name="tokenName" select="'Owner'"/>
		</xsl:call-template>
		<xsl:call-template name="PrintTokenInfo">
			<xsl:with-param name="token" select="Group"/>
			<xsl:with-param name="tokenName" select="'Primary Group'"/>
		</xsl:call-template>
		
	</xsl:template>
	
	<xsl:template match="Groups">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Groups:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Group"/>
		<xsl:apply-templates select="Errors"/>
	</xsl:template>
	
	<xsl:template match="Group">
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="5" />
		</xsl:call-template>
		<xsl:value-of select="@name" />
		<xsl:text> (Type=</xsl:text>
		<xsl:value-of select="@type" />
		<xsl:text> |  Attributes=</xsl:text>
		<xsl:value-of select="@attributes" />
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:for-each select="descendant::*">
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="8" />
			</xsl:call-template>
			<xsl:value-of select="name(.)" />
			<xsl:call-template name="PrintReturn"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="Privileges">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Privileges:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Privilege"/>
		<xsl:apply-templates select="Errors"/>
	</xsl:template>
	
	<xsl:template match="Privilege">
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="5" />
		</xsl:call-template>
		<xsl:value-of select="@name" />
		<xsl:text> (Attributes=</xsl:text>
		<xsl:value-of select="@attributes" />
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:choose>
			<xsl:when test="count(descendant::*) > 0">
				<xsl:for-each select="descendant::*">
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="8" />
					</xsl:call-template>
					<xsl:value-of select="name(.)" />
					<xsl:call-template name="PrintReturn"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>        SE_PRIVILEGE_DISABLED</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="Modules">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>--Loaded Modules--</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Entry Point       Image Size    Base Address   </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Module"/>
		<xsl:apply-templates select="Errors"/>
	</xsl:template>
	
	<xsl:template match="Module">
		<xsl:value-of select="@name" />
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>  Entry Point : </xsl:text>
		<xsl:value-of select="@entryPoint" />
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>   Image Size : </xsl:text>
		<xsl:value-of select="@imageSize" />
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text> Base Address : </xsl:text>
		<xsl:value-of select="@baseAddress" />
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:for-each select="Checksum">
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="13 - string-length(@type)" />
			</xsl:call-template>
			<xsl:value-of select="@type"/>
			<xsl:text> : </xsl:text>
			<xsl:value-of select="."/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:for-each>
		<xsl:call-template name="PrintReturn"/>
		
	</xsl:template>
	
	<xsl:template name="PrintTokenInfo">
		<xsl:param name="token"/>
		<xsl:param name="tokenName"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="13 - string-length($tokenName)" />
		</xsl:call-template>
		<xsl:value-of select="$tokenName"/>
		<xsl:text> : </xsl:text>
		<xsl:value-of select="$token/@name"/>
		<xsl:text> (Type=</xsl:text>
		<xsl:value-of select="$token/@type" />
		<xsl:text> | Attributes=</xsl:text>
		<xsl:value-of select="$token/@attributes" />
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>
