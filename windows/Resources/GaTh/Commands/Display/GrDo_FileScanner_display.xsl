<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="GrDo_FileScanner">
	   <xsl:apply-templates select="GrDoFileEntry"/>
	   <xsl:apply-templates select="GrDoFileInfoComplete"/>
	   
	   
	</xsl:template>
	
	<xsl:template name="GrDoStandardResult">
		<xsl:param name="resultval"/>
		<xsl:choose>
			<xsl:when test="(1 = number($resultval))">
				<xsl:text>TRUE</xsl:text>
			</xsl:when>
			<xsl:when test="(0 = number($resultval))">
				<xsl:text>FALSE</xsl:text>
			</xsl:when>
			<xsl:when test="(240 = number($resultval))">
				<xsl:text>NOT TESTED</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>ERROR</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="GrDoNegativeResult">
		<xsl:param name="resultval"/>
		<xsl:choose>
			<xsl:when test="(1 = number($resultval))">
				<xsl:text>FALSE</xsl:text>
			</xsl:when>
			<xsl:when test="(0 = number($resultval))">
				<xsl:text>TRUE</xsl:text>
			</xsl:when>
			<xsl:when test="(240 = number($resultval))">
				<xsl:text>NOT TESTED</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>ERROR</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="GrDoFileInfoComplete">
		<xsl:text>---------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Files scanned: </xsl:text>
		<xsl:value-of select="@filesScanned" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Files returned: </xsl:text>
		<xsl:value-of select="@filesReturned" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>---------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />

	</xsl:template>
		
	<xsl:template match="GrDoFileEntry">

		<xsl:choose>
			<xsl:when test="(1 = number(@FileStatus))">
				<xsl:text>File Name: </xsl:text>
				<xsl:value-of select="@FileName" />
				<xsl:call-template name="PrintReturn" />
				<xsl:for-each select="Hash">
					<xsl:if test="(number(@size) > 0)">
						<xsl:call-template name="Whitespace">
							<xsl:with-param name="i" select="8 - string-length(@type)"/>
						</xsl:call-template>
						<xsl:value-of select="@type"/>
						<xsl:text>: </xsl:text>
						<xsl:call-template name="Spaceout">
							<xsl:with-param name="i" select="8"/>
							<xsl:with-param name="string" select="."/>
						</xsl:call-template>
						<xsl:call-template name="PrintReturn"/>
					</xsl:if>
				</xsl:for-each>	
						<xsl:text>  Size: </xsl:text>
						<xsl:value-of select="@dwSize" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>  Calculated size: </xsl:text>
						<xsl:value-of select="@dwCalculatedFileSize" />
						<xsl:call-template name="PrintReturn" />
						<xsl:choose>
							<xsl:when test="(1 = number(@Is64))">
								<xsl:text>  Arch: x64</xsl:text>
								<xsl:call-template name="PrintReturn" />
							</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="(254 = number(@IsPE))">
								<xsl:text>  Resource Only: TRUE</xsl:text>
								<xsl:call-template name="PrintReturn" />
							</xsl:when>
						</xsl:choose>
						<xsl:text> File score : [</xsl:text>
						<xsl:value-of select="@score" />
						<xsl:text>]</xsl:text>
						<xsl:call-template name="PrintReturn" />

						<xsl:text>   Signed                      : </xsl:text>
						<!--
						<xsl:choose>
							<xsl:when test="(1 = number(@Signed))">
								<xsl:text>TRUE</xsl:text>
							</xsl:when>
							<xsl:when test="(2 = number(@Signed))">
								<xsl:text>VERIFIED</xsl:text>
							</xsl:when>
							<xsl:when test="(0 = number(@Signed))">
								<xsl:text>FALSE</xsl:text>
							</xsl:when>
							<xsl:when test="(240 = number(@Signed))">
								<xsl:text>NOT_TESTED</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>ERROR</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						-->
						<xsl:value-of select="@SignedStatus" />
						
						<xsl:call-template name="PrintReturn" />
						<xsl:choose>
							<xsl:when test="(2 = number(@Signed)) or (1 = number(@Signed))">
								<xsl:text>   Signed Info                 : </xsl:text>
								<xsl:choose>
									<xsl:when test="(1601 = substring-before(fileSignedTime, '-'))">
										<xsl:text>undated signature</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>signed on </xsl:text>
										<xsl:value-of select="substring-before(fileSignedTime, 'T')"/>
									</xsl:otherwise>
								</xsl:choose>	
								<xsl:text> signed by </xsl:text>
								<xsl:value-of select="@SignerName" />
								<xsl:choose>
									<xsl:when test="(2 = number(@Signed))">
										<xsl:text> with trusted root signed by </xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text> with untrusted root signed by </xsl:text>
									</xsl:otherwise>
								</xsl:choose>	
								<xsl:value-of select="@RootSignerName" />
								<xsl:call-template name="PrintReturn" />
							</xsl:when>
							<xsl:when test="(5 = number(@Signed))">
								<xsl:text>                                 </xsl:text>
								<xsl:value-of select="@SignerName" />
								<xsl:call-template name="PrintReturn" />
							</xsl:when>
						</xsl:choose>
								
						
						
						<xsl:text>   Microsoft binary            : </xsl:text>
						<!--
						<xsl:choose>
							<xsl:when test="(1 = number(@MS))">
								<xsl:text>CLAIMED</xsl:text>
							</xsl:when>
							<xsl:when test="(2 = number(@MS))">
								<xsl:text>VERIFIED</xsl:text>
							</xsl:when>
							<xsl:when test="(3 = number(@MS))">
								<xsl:text>IMPOSTER</xsl:text>
							</xsl:when>
							<xsl:when test="(0 = number(@MS))">
								<xsl:text>FALSE</xsl:text>
							</xsl:when>
							<xsl:when test="(240 = number(@MS))">
								<xsl:text>NOT_TESTED</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>ERROR</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						-->
						<xsl:value-of select="@MSStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   .NET binary                 : </xsl:text>
						<xsl:value-of select="@DotNetStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Packed                      : </xsl:text>
						
						<xsl:call-template name="GrDoStandardResult">
							   <xsl:with-param name="resultval" select="@Packed"/>
						</xsl:call-template> 
						
						<xsl:choose>
							<xsl:when test="(240 != number(@Packed))">
								<xsl:text>   [entropy: </xsl:text>
								<xsl:choose>
									<xsl:when test="(-1 = number(@dwEntropy))">
										<xsl:text>PE_HEADER_ERROR</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="@dwEntropy" />
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>; imports : </xsl:text>
								<xsl:choose>
									<xsl:when test="(-1 = number(@dwImportCount))">
										<xsl:text>PE_HEADER_ERROR</xsl:text>
									</xsl:when>
									<xsl:when test="(-6 = number(@dwImportCount))">
										<xsl:text>IMPORTS_ERROR</xsl:text>
									</xsl:when>
									<xsl:when test="(-7 = number(@dwImportCount))">
										<xsl:text>NO IMPORTS</xsl:text>
									</xsl:when>							
									<xsl:otherwise>
										<xsl:value-of select="@dwImportCount" />
									</xsl:otherwise>
								</xsl:choose>		
								<xsl:text>]</xsl:text>
							</xsl:when>	
						</xsl:choose>		
						
						<xsl:call-template name="PrintReturn" />				
						<xsl:text>   Invalid PE Header Size      : </xsl:text>
						<!--
						<xsl:call-template name="GrDoNegativeResult">
							   <xsl:with-param name="resultval" select="@HeaderSize"/>
						</xsl:call-template> 
						-->
						<xsl:value-of select="@HeaderSizeStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Invalid PE Section Names    : </xsl:text>
						<!--
						<xsl:call-template name="GrDoNegativeResult">
							   <xsl:with-param name="resultval" select="@SectionNames"/>
						</xsl:call-template> 
						-->
						<xsl:value-of select="@SectionNamesStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Invalid PE Section Order    : </xsl:text>
						<!--
						<xsl:call-template name="GrDoNegativeResult">
							   <xsl:with-param name="resultval" select="@SectionOrdering"/>
						</xsl:call-template> 
						-->
						<xsl:value-of select="@SectionOrderingStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Invalid PE Size of Code     : </xsl:text>
						<!--
						<xsl:call-template name="GrDoNegativeResult">
							   <xsl:with-param name="resultval" select="@SizeOfCode"/>
						</xsl:call-template> 
						-->
						<xsl:value-of select="@SizeOfCodeStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Invalid PE Checksum         : </xsl:text>
						<!--
						<xsl:choose>
							<xsl:when test="(5 = number(@PEChecksum))">
								<xsl:text>NULL_PE_CHECKSUM</xsl:text>
								<xsl:choose>
									<xsl:when test="1=(number(@MS))">
										<xsl:text> - MS files should have a checksum</xsl:text>
									</xsl:when>
									<xsl:when test="2=(number(@MS))">
										<xsl:text> - MS files should have a checksum</xsl:text>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="(1 = number(@PEChecksum))">
								<xsl:text>FALSE</xsl:text>
							</xsl:when>
							<xsl:when test="(0 = number(@PEChecksum))">
								<xsl:text>TRUE [PE: </xsl:text>
								<xsl:value-of select="@dwEmbeddedChecksum" />
								<xsl:text> Computed : </xsl:text>
								<xsl:value-of select="@dwComputedChecksum" />
								<xsl:text>]</xsl:text>
							</xsl:when>
							<xsl:when test="(240 = number(@PEChecksum))">
								<xsl:text>NOT_TESTED</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>ERROR</xsl:text>
							</xsl:otherwise>		
						</xsl:choose>
						-->
						<xsl:value-of select="@PEChecksumStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Invalid Linker Version      : </xsl:text>
						<!--<xsl:call-template name="GrDoNegativeResult">
							   <xsl:with-param name="resultval" select="@Linker"/>
						</xsl:call-template> 
						<xsl:choose>
							<xsl:when test="(0 = number(@Linker))">
								<xsl:choose>
									<xsl:when test="1=(number(@MS))">
										<xsl:text> - should not happen for MS files</xsl:text>
									</xsl:when>
									<xsl:when test="2=(number(@MS))">
										<xsl:text> - should not happen for MS files</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text> - Not an MS file, may not have been compilied with MS linker</xsl:text>
									</xsl:otherwise>								
								</xsl:choose>
								<xsl:text>FALSE</xsl:text>
							</xsl:when>
						</xsl:choose>
						-->
						<xsl:value-of select="@LinkerStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Invalid Timestamp           : </xsl:text>
						<xsl:choose>
							<xsl:when test="(0 = number(@TimeStamp))">
								<xsl:text>TRUE  [PE: </xsl:text>
								<xsl:value-of select="substring-before(fileLinkerTime, 'T')"/>
								<xsl:text> On-disk: </xsl:text>
								<xsl:value-of select="substring-before(fileDiskCreationTime, 'T')"/>
								<xsl:text>]</xsl:text>
							</xsl:when>
							<xsl:when test="255=(number(@TimeStamp))">
								<xsl:text>PE_HEADER_ERROR/NULL</xsl:text>
							</xsl:when>
							<xsl:when test="253=(number(@TimeStamp))">
								<xsl:text>FILE_TIMESTAMP_ERROR</xsl:text>
							</xsl:when>
							<xsl:when test="240=(number(@TimeStamp))">
								<xsl:text>NOT TESTED</xsl:text>
							</xsl:when>
							<xsl:when test="708992537=(number(@dwLinkerTimeStamp))">
								<xsl:text>TRUE  [delphi timestamp bug]</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>FALSE</xsl:text>
							</xsl:otherwise>		
						</xsl:choose>
						<xsl:call-template name="PrintReturn" />
						<xsl:choose>
							<xsl:when test="(1 = number(@ExportTimeStamp))">
								<xsl:text>   Invalid Export Timestamp    : </xsl:text>
								<xsl:text>TRUE  [Export: </xsl:text>
								<xsl:value-of select="substring-before(fileExportLinkerTime, 'T')"/>
								<xsl:text> Linker: </xsl:text>
								<xsl:value-of select="substring-before(fileLinkerTime, 'T')"/>
								<xsl:text> On-disk: </xsl:text>
								<xsl:value-of select="substring-before(fileDiskCreationTime, 'T')"/>
								<xsl:text>]</xsl:text>
								<xsl:call-template name="PrintReturn" />	
							</xsl:when>
						</xsl:choose>	
						<xsl:choose>
							<xsl:when test="(1 = number(@ResourceTimeStamp))">
								<xsl:text>   Invalid Resource Timestamp  : </xsl:text>
								<xsl:text>TRUE  [Resource: </xsl:text>
								<xsl:value-of select="substring-before(fileResourceLinkerTime, 'T')"/>
								<xsl:text> Linker: </xsl:text>
								<xsl:value-of select="substring-before(fileLinkerTime, 'T')"/>
								<xsl:text> On-disk: </xsl:text>
								<xsl:value-of select="substring-before(fileDiskCreationTime, 'T')"/>
								<xsl:text>]</xsl:text>
								<xsl:call-template name="PrintReturn" />	
							</xsl:when>
						</xsl:choose>	
						<xsl:choose>
							<xsl:when test="(1 = number(@SignedTimeStamp))">
								<xsl:text>   Invalid Signed Timestamp    : </xsl:text>
								<xsl:text>TRUE  [Signed: </xsl:text>
								<xsl:value-of select="substring-before(fileSignedTime, 'T')"/>
								<xsl:text> Linker: </xsl:text>
								<xsl:value-of select="substring-before(fileLinkerTime, 'T')"/>
								<xsl:text> On-disk: </xsl:text>
								<xsl:value-of select="substring-before(fileDiskCreationTime, 'T')"/>
								<xsl:text>]</xsl:text>
								<xsl:call-template name="PrintReturn" />	
							</xsl:when>
						</xsl:choose>					
						<xsl:text>   Cache Mismatch              : </xsl:text>
						<xsl:value-of select="@CacheMatchStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Name Mismatch               : </xsl:text>
						<xsl:value-of select="@NameMatchStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:choose>
							<xsl:when test="(1 = number(@ExportNameMatch))">
								<xsl:text>   Export Name Mismatch        : </xsl:text>
								<xsl:text>TRUE  (Export name: </xsl:text>
								<xsl:value-of select="@DllExportName"/>
								<xsl:text>)</xsl:text>
								<xsl:call-template name="PrintReturn" />	
							</xsl:when>
						</xsl:choose>	
						<xsl:text>   Linker Version Time         : </xsl:text>
						<xsl:value-of select="@LinkerVersionTimeStatus" />
						<xsl:text>  </xsl:text>
						<xsl:value-of select="substring-before(fileLinkerTime, 'T')"/>
						<xsl:text>  Major: </xsl:text>
						<xsl:value-of select="@MajorLinkerVersion" />
						<xsl:text>  Minor: </xsl:text>
						<xsl:value-of select="@MinorLinkerVersion" />
						<xsl:choose>
							<xsl:when test="(4 = number(@MajorLinkerVersion)) and (0 = number(@MinorLinkerVersion))">
								<xsl:text> --Visual Studio (original)</xsl:text>
							</xsl:when>
							<xsl:when test="(5 = number(@MajorLinkerVersion)) and (0 = number(@MinorLinkerVersion))">
								<xsl:text> --Visual Studio 97</xsl:text>
							</xsl:when>
							<xsl:when test="(6 = number(@MajorLinkerVersion)) and (0 = number(@MinorLinkerVersion))">
										<xsl:text> --Visual Studio 6</xsl:text>
							</xsl:when>
							<xsl:when test="(7 = number(@MajorLinkerVersion))">
								<xsl:choose>
									<xsl:when test="(0 = number(@MinorLinkerVersion))">
										<xsl:text> --Visual Studio 2003</xsl:text>
									</xsl:when>
									<xsl:when test="(10 = number(@MinorLinkerVersion))">
										<xsl:text> --Visual Studio 2003 .NET</xsl:text>
									</xsl:when>
								</xsl:choose>	
							</xsl:when>
							<xsl:when test="(8 = number(@MajorLinkerVersion)) and (0 = number(@MinorLinkerVersion))">
										<xsl:text> --Visual Studio 2005</xsl:text>
							</xsl:when>
							<xsl:when test="(9 = number(@MajorLinkerVersion)) and (0 = number(@MinorLinkerVersion))">
										<xsl:text> --Visual Studio 2008</xsl:text>
							</xsl:when>
							<xsl:when test="(10 = number(@MajorLinkerVersion)) and (0 = number(@MinorLinkerVersion))">
										<xsl:text> --Visual Studio 2010</xsl:text>
							</xsl:when>
							
						</xsl:choose>	
						
						<xsl:call-template name="PrintReturn" />
						
						<xsl:text>   Non-relocatable binary      : </xsl:text>
						<xsl:value-of select="@RelocatableStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Invalid Attributes          : </xsl:text>
						<xsl:value-of select="@InvalidAttributesStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Driver In Invalid Location  : </xsl:text>
						<xsl:value-of select="@InvalidDrvLocStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Has no embedded resources   : </xsl:text>
						<xsl:value-of select="@NoResourcesStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Has shady resources         : </xsl:text>
						<xsl:value-of select="@ResDataStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Has no version information  : </xsl:text>
						<xsl:value-of select="@NoVersionInfoStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>   Executable has extra data   : </xsl:text>
						<xsl:value-of select="@TailDataStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:choose>
							<xsl:when test="GrDoFilePEData">
								<xsl:apply-templates select="GrDoFilePEData"/>
							</xsl:when>			
						</xsl:choose>
						<!--
							<xsl:when test="GrDoPEInformation">

						<xsl:text>  Executable found in ADS     : </xsl:text>
						<xsl:value-of select="@ADSFileNameStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>  Keylogger		              : </xsl:text>
						<xsl:value-of select="@KeyloggerStatus" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>  Linker Version : </xsl:text>
						<xsl:value-of select="@dwLinkerVersion" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>  Computed Checksum : </xsl:text>
						<xsl:value-of select="@dwComputedChecksum" />
						<xsl:call-template name="PrintReturn" />
						<xsl:text>  Embedded Checksum : </xsl:text>
						<xsl:value-of select="@dwEmbeddedChecksum" />
						<xsl:call-template name="PrintReturn" />
						<xsl:call-template name="PrintReturn" />
						-->
			</xsl:when>
			
			<xsl:when test="(4 = number(@FileStatus))">
				<xsl:text>File Name: </xsl:text>
				<xsl:value-of select="@FileName" />
				<xsl:call-template name="PrintReturn" />
				
				<xsl:text>   Signed                      : </xsl:text>

				<xsl:value-of select="@SignedStatus" />
				
				<xsl:call-template name="PrintReturn" />
				<xsl:choose>
					<xsl:when test="(2 = number(@Signed)) or (1 = number(@Signed))">
						<xsl:text>   Signed Info                 : </xsl:text>
						<xsl:choose>
							<xsl:when test="(1601 = substring-before(fileSignedTime, '-'))">
								<xsl:text>undated signature</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>signed on </xsl:text>
								<xsl:value-of select="substring-before(fileSignedTime, 'T')"/>
							</xsl:otherwise>
						</xsl:choose>	
						<xsl:text> signed by </xsl:text>
						<xsl:value-of select="@SignerName" />
						<xsl:choose>
							<xsl:when test="(2 = number(@Signed))">
								<xsl:text> with trusted root signed by </xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text> with untrusted root signed by </xsl:text>
							</xsl:otherwise>
						</xsl:choose>	
						<xsl:value-of select="@RootSignerName" />
						<xsl:call-template name="PrintReturn" />
					</xsl:when>
					<xsl:when test="(5 = number(@Signed))">
						<xsl:text>                                 </xsl:text>
						<xsl:value-of select="@SignerName" />
						<xsl:call-template name="PrintReturn" />
					</xsl:when>
				</xsl:choose>
								
			</xsl:when>
			<!--
			<xsl:otherwise>
				<xsl:text>   ERROR - </xsl:text>
				<xsl:value-of select="@FileStatusMsg" />
				<xsl:call-template name="PrintReturn" />
			</xsl:otherwise>
			-->
		</xsl:choose>
		<!--<xsl:call-template name="PrintReturn" />-->

	</xsl:template>
	
	<xsl:template match="GrDoFilePEData">
		<xsl:call-template name="PrintReturn" />
		<xsl:text> PE header data</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    Dos magic                      : </xsl:text>
		<xsl:value-of select="@Dos_magic" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    Dos_lfanew                     : </xsl:text>
		<xsl:value-of select="@Dos_lfanew" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_Machine                     : </xsl:text>
		<xsl:value-of select="@NT_Machine" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_NumberofSections            : </xsl:text>
		<xsl:value-of select="@NT_NumberofSections" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_TimeDateStamp               : </xsl:text>
		<xsl:value-of select="@NT_TimeDateStamp" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_NumberofSymbols             : </xsl:text>
		<xsl:value-of select="@NT_NumberofSymbols" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfOptionalHeader        : </xsl:text>
		<xsl:value-of select="@NT_SizeOfOptionalHeader" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_Characteristics             : </xsl:text>
		<xsl:value-of select="@NT_Characteristics" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_Magic                       : </xsl:text>
		<xsl:value-of select="@NT_Magic" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MajorLinkerVersion          : </xsl:text>
		<xsl:value-of select="@NT_MajorLinkerVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MinorLinkerVersion          : </xsl:text>
		<xsl:value-of select="@NT_MinorLinkerVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfCode                  : </xsl:text>
		<xsl:value-of select="@NT_SizeOfCode" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfInitializedData       : </xsl:text>
		<xsl:value-of select="@NT_SizeOfInitializedData" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfUninitializedData     : </xsl:text>
		<xsl:value-of select="@NT_SizeOfUninitializedData" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_AddressOfEntryPoint         : </xsl:text>
		<xsl:value-of select="@NT_AddressOfEntryPoint" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_BaseOfCode                  : </xsl:text>
		<xsl:value-of select="@NT_BaseOfCode" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_BaseOfData                  : </xsl:text>
		<xsl:value-of select="@NT_BaseOfData" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_ImageBase                   : </xsl:text>
		<xsl:value-of select="@NT_ImageBase" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SectionAlignment            : </xsl:text>
		<xsl:value-of select="@NT_SectionAlignment" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_FileAlignment               : </xsl:text>
		<xsl:value-of select="@NT_FileAlignment" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MajorOperatingSystemVersion : </xsl:text>
		<xsl:value-of select="@NT_MajorOperatingSystemVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MinorOperatingSystemVersion : </xsl:text>
		<xsl:value-of select="@NT_MinorOperatingSystemVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MajorImageVersion           : </xsl:text>
		<xsl:value-of select="@NT_MajorImageVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MinorImageVersion           : </xsl:text>
		<xsl:value-of select="@NT_MinorImageVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MajorSubsystemVersion       : </xsl:text>
		<xsl:value-of select="@NT_MajorSubsystemVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MinorSubsystemVersion       : </xsl:text>
		<xsl:value-of select="@NT_MinorSubsystemVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_Win32VersionValue           : </xsl:text>
		<xsl:value-of select="@NT_Win32VersionValue" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfImage                 : </xsl:text>
		<xsl:value-of select="@NT_SizeOfImage" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfHeaders               : </xsl:text>
		<xsl:value-of select="@NT_SizeOfHeaders" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_CheckSum                    : </xsl:text>
		<xsl:value-of select="@NT_CheckSum" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_Subsystem                   : </xsl:text>
		<xsl:value-of select="@NT_Subsystem" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_DllCharacteristics          : </xsl:text>
		<xsl:value-of select="@NT_DllCharacteristics" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfStackReserve          : </xsl:text>
		<xsl:value-of select="@NT_SizeOfStackReserve" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfStackCommit           : </xsl:text>
		<xsl:value-of select="@NT_SizeOfStackCommit" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfHeapReserve           : </xsl:text>
		<xsl:value-of select="@NT_SizeOfHeapReserve" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfHeapCommit            : </xsl:text>
		<xsl:value-of select="@NT_SizeOfHeapCommit" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_LoaderFlags                 : </xsl:text>
		<xsl:value-of select="@NT_LoaderFlags" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_NumberOfRvaAndSizes         : </xsl:text>
		<xsl:value-of select="@NT_NumberOfRvaAndSizes" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>  Sections         Name          SizeofRawData   VirtualAddress  Characteristics</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>  ----------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:apply-templates select="GrDoPESection"/>
		
		<xsl:call-template name="PrintReturn" />
		<xsl:text>  Imports</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>  ----------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		
		<xsl:apply-templates select="GrDoImportsDLL"/>
		
		<xsl:call-template name="PrintReturn" />

	</xsl:template>
	<xsl:template match="GrDoPESection">
		<xsl:text>                  </xsl:text>
		<xsl:value-of select="@SectionName" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="15 - string-length(@SectionName)"/>
		</xsl:call-template>
		<xsl:value-of select="@SizeofRawData" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="16 - string-length(@SizeofRawData)"/>
		</xsl:call-template>
		<xsl:value-of select="@VirtualAddress" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="16 - string-length(@VirtualAddress)"/>
		</xsl:call-template>
		<xsl:value-of select="@Characteristics" />
		
		<xsl:call-template name="PrintReturn" />

	</xsl:template>
	
	<xsl:template match="GrDoImportsDLL">
		<xsl:text>     DLL : </xsl:text>
		<xsl:value-of select="@DLLName" />
		<xsl:call-template name="PrintReturn" />
		<xsl:apply-templates select="GrDoImportedFunction"/>

	</xsl:template>
	
		<xsl:template match="GrDoImportedFunction">
		<xsl:text>                </xsl:text>
		<xsl:value-of select="@functionName" />
		<xsl:call-template name="PrintReturn" />
		

	</xsl:template>
	

</xsl:transform>