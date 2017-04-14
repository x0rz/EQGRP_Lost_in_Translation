<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:param name="all" select="'false'"/>
	<xsl:param name="astyped" select="'false'"/>
	<xsl:param name="verbose" select="'false'"/>

	<xsl:template match="LocalCommand">
		<xsl:if test="($all = 'true') or (Status = 'RUNNING')">
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="4-string-length(Id)"/>
			</xsl:call-template>
			<xsl:value-of select="Id"/>
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="3"/>
			</xsl:call-template>
			<xsl:value-of select="Status"/>
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="12-string-length(Status)"/>
			</xsl:call-template>
			<xsl:value-of select="TargetAddress"/>
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="18-string-length(TargetAddress)"/>
			</xsl:call-template>
			<xsl:value-of select="TaskId"/>
			<xsl:call-template name="PrintReturn"/>
			
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="9"/>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="($astyped = 'true') or (string-length(FullCommand) = 0)">
					<xsl:value-of select="CommandAsTyped"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="FullCommand"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="PrintReturn"/>
			
			<xsl:text>         SENT: </xsl:text>
			<xsl:call-template name="PrintNumberWithCommas">
				<xsl:with-param name="skipBillions" select="'true'"/>
				<xsl:with-param name="number" select="BytesSent"/>
			</xsl:call-template>
			<xsl:text> bytes</xsl:text>
			<xsl:text>    RECV: </xsl:text>
			<xsl:call-template name="PrintNumberWithCommas">
				<xsl:with-param name="skipBillions" select="'true'"/>
				<xsl:with-param name="number" select="BytesReceived"/>
			</xsl:call-template>
			<xsl:text> bytes</xsl:text>
			<xsl:call-template name="PrintReturn"/>
			
			<xsl:if test="$verbose = 'true'">
				<xsl:if test="Rpc">
					<xsl:text>     RPCs: </xsl:text>
					<xsl:apply-templates select="Rpc"/>
					<xsl:call-template name="PrintReturn"/>
				</xsl:if>
				
				<xsl:if test="Thread">
					<xsl:text>     Threads: </xsl:text>
					<xsl:call-template name="PrintReturn"/>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="RemoteCommand">
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="4-string-length(Id)"/>
		</xsl:call-template>
		<xsl:value-of select="Id"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="3"/>
		</xsl:call-template>
		
		<xsl:if test="Name">
			<xsl:value-of select="Name"/>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
			
		<xsl:if test="Thread">
			<xsl:text>     Threads: </xsl:text>
			<xsl:call-template name="PrintReturn"/>
			<xsl:apply-templates select="Thread"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="Rpc">
		<xsl:value-of select="."/>
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<xsl:template match="Thread">
		<xsl:text>        </xsl:text>
		<xsl:text>id=</xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text> cmd=</xsl:text>
		<xsl:value-of select="@cmdId"/>
		<xsl:text> task=</xsl:text>
		<xsl:value-of select="@taskId"/>
		<xsl:text> rpc=</xsl:text>
		<xsl:value-of select="@rpcId"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="@interface"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="@provider"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>