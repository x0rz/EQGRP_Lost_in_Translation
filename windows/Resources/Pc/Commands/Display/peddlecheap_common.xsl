<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="RemoteAddress"/>
	
	<xsl:template match="Library">
		<!--
		<xsl:call-template name="PrintTab"/>
		<xsl:value-of select="Name"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="Size"/>
		<xsl:text> bytes)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		-->
	</xsl:template>
	
	<xsl:template match="ImplantInfo">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Remote Information</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>    PC Version : </xsl:text>
		<xsl:value-of select="Version"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>         PC Id : </xsl:text>
		<xsl:value-of select="Id"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>       Arch-Os : </xsl:text>
		<xsl:value-of select="Architecture"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="Platform"/>
		<xsl:text> (compiled </xsl:text>
		<xsl:value-of select="CompiledArchitecture"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="CompiledPlatform"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>   Session Key :</xsl:text>
		<xsl:for-each select="SessionKey/Value">
			<xsl:text> </xsl:text>
			<xsl:value-of select="."/>
		</xsl:for-each>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="RemoteOsVersion">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Remote OS</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>             Arch : </xsl:text>
		<xsl:value-of select="@arch"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>    Compiled Arch : </xsl:text>
		<xsl:value-of select="@compiledArch"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>         Platform : </xsl:text>
		<xsl:value-of select="@platform"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>Compiled Platform : </xsl:text>
		<xsl:value-of select="@compiledPlatform"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>          Version : </xsl:text>
		<xsl:value-of select="@major"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="@minor"/>
		<xsl:if test="@platform = 'winnt'">
			<xsl:choose>
				<xsl:when test="@major = 4">
					<xsl:text> (Windows NT)</xsl:text>
				</xsl:when>
				<xsl:when test="(@major = 5) and (@minor = 0)">
					<xsl:text> (Windows 2000)</xsl:text>
				</xsl:when>
				<xsl:when test="(@major = 5) and (@minor = 1)">
					<xsl:text> (Windows XP)</xsl:text>
				</xsl:when>
				<xsl:when test="(@major = 5) and (@minor = 2)">
					<xsl:text> (Windows 2003)</xsl:text>
				</xsl:when>
				<xsl:when test="(@major = 6) and (@minor = 0)">
					<xsl:text> (Windows Vista/2008)</xsl:text>
				</xsl:when>
				<xsl:when test="(@major = 6) and (@minor = 1)">
					<xsl:text> (Windows 7)</xsl:text>
				</xsl:when>
				<xsl:otherwise>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:choose>
			<xsl:when test="@platform = 'winnt'">
				<xsl:text>     Service Pack : </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>         Revision : </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="@revision"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>    C Lib Version : </xsl:text>
		<xsl:value-of select="@cMajor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="@cMinor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="@cRevision"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="UserChoice">
		<xsl:text>USER CHOICE : </xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="DependencyInfo">
		<xsl:text>Dependent Library</xsl:text>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>      File Name : </xsl:text>
		<xsl:value-of select="@fileName"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>Attempt to send : </xsl:text>
		<xsl:value-of select="@sendingPayload"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>  Original Size : </xsl:text>
		<xsl:value-of select="@origSize"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>      Send Size : </xsl:text>
		<xsl:value-of select="@sendSize"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>       Checksum : </xsl:text>
		<xsl:value-of select="@checksum"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="PayloadInfo">
		<xsl:text>Payload </xsl:text>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>      File Name : </xsl:text>
		<xsl:value-of select="@fileName"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>   Send payload : </xsl:text>
		<xsl:value-of select="@sendingPayload"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>  Original Size : </xsl:text>
		<xsl:value-of select="@origSize"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>      Send Size : </xsl:text>
		<xsl:value-of select="@sendSize"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>       Checksum : </xsl:text>
		<xsl:value-of select="@checksum"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="RunLibrary">
		<xsl:text>           Name : </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>           Path : </xsl:text>
		<xsl:value-of select="@path"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>         Export : </xsl:text>
		<xsl:value-of select="@export"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="EggPayloadInfo">
		<xsl:text>Payload for Egg</xsl:text>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>      File Name : </xsl:text>
		<xsl:value-of select="@fileName"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>   Send payload : </xsl:text>
		<xsl:value-of select="@sendingPayload"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>  Original Size : </xsl:text>
		<xsl:value-of select="@origSize"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>      Send Size : </xsl:text>
		<xsl:value-of select="@sendSize"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>       Checksum : </xsl:text>
		<xsl:value-of select="@checksum"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="EggInfo">
		<xsl:text>Egg</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>      File Name : </xsl:text>
		<xsl:value-of select="@fileName"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>  Original Size : </xsl:text>
		<xsl:value-of select="@origSize"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>      Send Size : </xsl:text>
		<xsl:value-of select="@sendSize"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>       Checksum : </xsl:text>
		<xsl:value-of select="@checksum"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
</xsl:transform>