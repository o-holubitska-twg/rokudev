' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
  ' set the name of the function in the Task node component to be executed when the state field changes to RUN
  ' in our case this method executed after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
  m.top.functionName = "GetContent"
end sub

sub GetContent()
  ' request the content feed from the API
  xfer = CreateObject("roURLTransfer")
  xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
  xfer.SetURL("https://www.omdbapi.com/?apikey=9b2f5ea&s=Batman&page=2")
  rsp = xfer.GetToString()
  rootChildren = []
  rows = {}

  ' parse the feed and build a tree of ContentNodes to populate the GridView
  json = ParseJson(rsp)
  if json <> invalid
    for each category in json
      value = json.Lookup(category)
      if Type(value) = "roArray" ' if parsed key value having other objects in it
        if category <> "series" ' ignore series for this phase
          row = {}
          row.title = category
          row.children = []
          for each item in value ' parse items and push them to row
            itemData = GetItemData(item)
            row.children.Push(itemData)
          end for
          rootChildren.Push(row)
        end if
      end if
    end for
    ' set up a root ContentNode to represent rowList on the GridScreen
    contentNode = CreateObject("roSGNode", "ContentNode")
    contentNode.Update({
      children: rootChildren
    }, true)
    m.top.content = contentNode
  end if
end sub

function GetItemData(video as object) as object
  item = {}
  item.description = video.Plot
  item.hdPosterURL = video.Poster
  item.title = video.Title
  item.releaseDate = video.Year
  item.id = video.imdbID
  item.length = video.Runtime

  return item
end function