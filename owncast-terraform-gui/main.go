package main

import (
	"context"
	"fmt"

	"github.com/hashicorp/terraform-exec/tfexec"
	"github.com/lxn/walk"
	. "github.com/lxn/walk/declarative"
)

func main() {
	var outTE *walk.TextEdit

	MainWindow{
		Title:   "Owncast Deployer",
		Size: Size{
			Width: 600,
			Height: 400,
		},
		Layout:  VBox{},
		Children: []Widget{
			HSplitter{
				Children: []Widget{
					TextEdit{
						AssignTo: &outTE,
						ReadOnly: true,
					},
				},
			},
			PushButton{
				Text: "Deploy",
				OnClicked: func () {
					RunTerraformApply(outTE)
				},
			},
			PushButton{
				Text: "Destroy",
				OnClicked: func () {
					RunTerraformDestroy(outTE)
				},
			},
		},
	}.Run()
}

const (
	workingDir string = `path to your terraform directory`
	execPath string = `path to your terraform executable`
)

func RunTerraformApply(outTE *walk.TextEdit) {
	tf, err := tfexec.NewTerraform(workingDir, execPath)
	if err != nil {
		outTE.AppendText(fmt.Sprintf("error running NewTerraform:\n%s", err))
	}
	outTE.AppendText("Successfully found terraform")

	err = tf.Init(context.Background())
	if err != nil {
		outTE.AppendText(fmt.Sprintf("error running Init:\n%s", err))
		return
	}

	err = tf.Apply(context.Background())
	if err != nil {
		outTE.AppendText(fmt.Sprintf("error running Apply:\n%s", err))
		return
	}

	output, err := tf.Output(context.Background())
	if err != nil {
		outTE.AppendText(fmt.Sprintf("error getting outputs:\n%s", err))
		return
	}

	outTE.SetText("Stream key: " + string(output["stream_key"].Value))
}

func RunTerraformDestroy(outTE *walk.TextEdit) {
	tf, err := tfexec.NewTerraform(workingDir, execPath)
	if err != nil {
		outTE.AppendText(fmt.Sprintf("error running NewTerraform:\n%s", err))
		return
	}

	err = tf.Init(context.Background())
	if err != nil {
		outTE.AppendText(fmt.Sprintf("error running Init:\n%s", err))
		return
	}

	err = tf.Destroy(context.Background())
	if err != nil {
		outTE.AppendText(fmt.Sprintf("error running Destroy:\n%s", err))
		return
	}

	outTE.SetText("Destroy finished")
}